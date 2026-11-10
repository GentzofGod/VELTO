// Supabase Edge Function: wisepilot-agent
// Path: supabase/functions/wisepilot-agent/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { message, conversation_history = [] } = await req.json();
    if (!message) {
      return new Response(
        JSON.stringify({
          error_code: "ERR_VAL_MISSING_MESSAGE",
          domain: "ERR_DOMAIN_VALIDATION",
          message: "User message is required.",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiKey) {
      return new Response(
        JSON.stringify({
          error_code: "ERR_CONFIG_MISSING",
          domain: "ERR_DOMAIN_AI",
          message: "Gemini API key is not configured.",
        }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const systemInstruction = `You are WisePilot, the intelligent cross-border payment co-pilot for Veltro.
Your mission is to guide users through international payments, calculate transfer fees transparently, compare payment routes, and evaluate fraud risks.

Strict Guidelines:
1. Strictly zero emojis anywhere in your responses.
2. Be concise, transparent, and accurate regarding fees and exchange rates.
3. You cannot execute payments or move money autonomously. When a user wants to transfer money, explain the breakdown and propose a structured payment review card for their explicit approval.
4. When suspicious messages, advance fee requests, or fake payment proofs are described, advise extreme caution and recommend running Veltro Shield.
5. In case of missing or unverified data, state clearly that live verification is required rather than guessing.`;

    const toolsDeclaration = [
      {
        function_declarations: [
          {
            name: "calculate_transfer_fee",
            description: "Calculates fees, FX rates, and recipient delivery amounts.",
            parameters: {
              type: "OBJECT",
              properties: {
                source_currency: { type: "STRING", description: "3-letter sender currency code" },
                target_currency: { type: "STRING", description: "3-letter recipient currency code" },
                send_amount: { type: "NUMBER", description: "Gross amount to send" },
              },
              required: ["source_currency", "target_currency", "send_amount"],
            },
          },
          {
            name: "check_country_support",
            description: "Checks PayPal corridor regulations and payout options.",
            parameters: {
              type: "OBJECT",
              properties: {
                country_code: { type: "STRING", description: "2-letter ISO country code" },
              },
              required: ["country_code"],
            },
          },
        ],
      },
    ];

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiKey}`;

    const contents = [
      ...conversation_history.map((h: { role: string; text: string }) => ({
        role: h.role === "assistant" ? "model" : "user",
        parts: [{ text: h.text }],
      })),
      { role: "user", parts: [{ text: message }] },
    ];

    const aiRes = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents,
        system_instruction: { parts: [{ text: systemInstruction }] },
        tools: toolsDeclaration,
        generationConfig: { temperature: 0.2 },
      }),
    });

    if (!aiRes.ok) {
      const errText = await aiRes.text();
      return new Response(
        JSON.stringify({
          error_code: "ERR_AI_INFERENCE_FAILED",
          domain: "ERR_DOMAIN_AI",
          message: "WisePilot assistant service encountered an error.",
          technical_details: errText,
        }),
        { status: aiRes.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const aiData = await aiRes.json();
    const candidate = aiData.candidates?.[0]?.content?.parts?.[0];

    // Check if Gemini invoked a tool
    if (candidate?.functionCall) {
      const fnName = candidate.functionCall.name;
      const args = candidate.functionCall.args;

      let toolResult: Record<string, unknown> = {};
      if (fnName === "calculate_transfer_fee") {
        const fee = 3.50;
        const rate = args.target_currency === "KES" ? 129.50 : args.target_currency === "NGN" ? 1620.00 : 1.08;
        const netAmount = (args.send_amount - fee) * rate;
        toolResult = {
          source_currency: args.source_currency,
          target_currency: args.target_currency,
          send_amount: args.send_amount,
          fee: fee,
          exchange_rate: rate,
          recipient_amount: parseFloat(netAmount.toFixed(2)),
          delivery_estimate: "15 minutes via PayPal",
        };
      } else if (fnName === "check_country_support") {
        toolResult = {
          country_code: args.country_code,
          supported: true,
          sandbox_available: true,
          payout_methods: ["PayPal Balance", "Linked Bank Account", "Card Deposit"],
        };
      }

      return new Response(
        JSON.stringify({
          type: "TOOL_CALL",
          function_name: fnName,
          arguments: args,
          result: toolResult,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({
        type: "MESSAGE",
        reply: candidate?.text || "I am available to assist with international payment queries.",
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error_code: "ERR_SERVER_EXCEPTION",
        domain: "ERR_DOMAIN_NETWORK",
        message: "An unhandled exception occurred in the WisePilot agent.",
        technical_details: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
