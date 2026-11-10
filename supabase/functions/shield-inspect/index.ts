// Supabase Edge Function: shield-inspect
// Path: supabase/functions/shield-inspect/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface ScanRequest {
  scan_type: "MESSAGE" | "LINK" | "RECEIPT" | "INVOICE";
  input_text: string;
  claimed_transaction_id?: string;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body: ScanRequest = await req.json();
    if (!body.scan_type || !body.input_text) {
      return new Response(
        JSON.stringify({
          error_code: "ERR_VAL_MISSING_INPUT",
          domain: "ERR_DOMAIN_VALIDATION",
          message: "Scan type and input content are required for analysis.",
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
          message: "Gemini API key is not configured on backend.",
        }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // System prompt enforcing objective risk indicators, zero emojis, and structured JSON output
    const systemPrompt = `You are Veltro Shield, an AI security analysis engine specialized in cross-border payment fraud detection.
Your purpose is to examine submitted messages, links, receipts, or invoices for fraud and scam risk indicators.

Rules:
1. Output strictly valid JSON matching the specified schema.
2. Present findings as risk indicators and probabilities, not defamatory accusations.
3. Screenshots or visual receipts are NEVER proof of settlement; only direct payment provider records can verify funds.
4. Risk tiers: LOW (0-24), MEDIUM (25-59), HIGH (60-84), CRITICAL (85-100).
5. Strictly zero emojis anywhere in the output text. Use clear, professional language.`;

    const userPrompt = `Analyze this ${body.scan_type} payload:
${body.input_text}

Claimed Transaction ID: ${body.claimed_transaction_id || "None provided"}

Return JSON in this format:
{
  "risk_tier": "LOW" | "MEDIUM" | "HIGH" | "CRITICAL",
  "confidence_score": 0.0 - 1.0,
  "summary": "Clear, objective summary without emojis",
  "risk_indicators": [
    {
      "indicator_code": "CODE_NAME",
      "severity": "LOW" | "MEDIUM" | "HIGH" | "CRITICAL",
      "description": "Specific finding explanation"
    }
  ],
  "recommended_actions": [
    "Actionable step 1",
    "Actionable step 2"
  ]
}`;

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiKey}`;

    const aiRes = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [
          { role: "user", parts: [{ text: `${systemPrompt}\n\n${userPrompt}` }] }
        ],
        generationConfig: {
          response_mime_type: "application/json",
          temperature: 0.1,
        },
      }),
    });

    if (!aiRes.ok) {
      const errText = await aiRes.text();
      return new Response(
        JSON.stringify({
          error_code: "ERR_AI_ANALYSIS_FAILED",
          domain: "ERR_DOMAIN_AI",
          message: "Gemini AI inference service returned an error.",
          technical_details: errText,
        }),
        { status: aiRes.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const aiData = await aiRes.json();
    const rawContent = aiData.candidates?.[0]?.content?.parts?.[0]?.text;
    const parsed = JSON.parse(rawContent || "{}");

    return new Response(
      JSON.stringify({
        scan_id: crypto.randomUUID(),
        timestamp: new Date().toISOString(),
        scan_type: body.scan_type,
        ...parsed,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error_code: "ERR_SERVER_EXCEPTION",
        domain: "ERR_DOMAIN_NETWORK",
        message: "An unhandled exception occurred during security analysis.",
        technical_details: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
