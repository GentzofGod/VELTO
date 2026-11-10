// Supabase Edge Function: create-paypal-order
// Path: supabase/functions/create-paypal-order/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, paypal-request-id",
};

interface OrderPayload {
  send_amount: number;
  source_currency: string;
  target_currency: string;
  recipient_identifier: string;
  idempotency_key?: string;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({
          error_code: "ERR_AUTH_MISSING",
          domain: "ERR_DOMAIN_AUTH",
          message: "Missing Authorization header.",
        }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) {
      return new Response(
        JSON.stringify({
          error_code: "ERR_AUTH_INVALID",
          domain: "ERR_DOMAIN_AUTH",
          message: "User authentication failed or session expired.",
        }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const body: OrderPayload = await req.json();
    if (!body.send_amount || body.send_amount <= 0 || !body.source_currency || !body.recipient_identifier) {
      return new Response(
        JSON.stringify({
          error_code: "ERR_VAL_INVALID_INPUT",
          domain: "ERR_DOMAIN_VALIDATION",
          message: "Invalid transfer parameters. Ensure amount, currency, and recipient are specified.",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const clientId = Deno.env.get("PAYPAL_SANDBOX_CLIENT_ID");
    const clientSecret = Deno.env.get("PAYPAL_SANDBOX_CLIENT_SECRET");
    const baseUrl = Deno.env.get("PAYPAL_API_BASE_URL") || "https://api-m.sandbox.paypal.com";

    if (!clientId || !clientSecret) {
      return new Response(
        JSON.stringify({
          error_code: "ERR_CONFIG_MISSING",
          domain: "ERR_DOMAIN_PAYPAL",
          message: "PayPal sandbox credentials not configured on backend.",
        }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 1. Get OAuth Token from PayPal Sandbox
    const basicAuth = btoa(`${clientId}:${clientSecret}`);
    const tokenRes = await fetch(`${baseUrl}/v1/oauth2/token`, {
      method: "POST",
      headers: {
        "Authorization": `Basic ${basicAuth}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: "grant_type=client_credentials",
    });

    if (!tokenRes.ok) {
      const errText = await tokenRes.text();
      return new Response(
        JSON.stringify({
          error_code: "ERR_PAYPAL_AUTH",
          domain: "ERR_DOMAIN_PAYPAL",
          message: "Failed to authenticate with PayPal Sandbox.",
          technical_details: errText,
        }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const tokenData = await tokenRes.json();
    const accessToken = tokenData.access_token;

    // 2. Compute Fee & Breakdown
    const baseFee = 3.50; // Transparent fixed transfer charge
    const totalAmount = body.send_amount;
    const netSend = (totalAmount - baseFee).toFixed(2);
    const requestId = body.idempotency_key || crypto.randomUUID();

    // 3. Create Order via PayPal Orders v2 API
    const orderPayload = {
      intent: "CAPTURE",
      purchase_units: [
        {
          reference_id: `VELTRO_${Date.now()}`,
          description: `Veltro International Transfer to ${body.recipient_identifier}`,
          amount: {
            currency_code: body.source_currency,
            value: totalAmount.toFixed(2),
            breakdown: {
              item_total: {
                currency_code: body.source_currency,
                value: netSend,
              },
              handling: {
                currency_code: body.source_currency,
                value: baseFee.toFixed(2),
              },
            },
          },
          items: [
            {
              name: `Cross-border payout to ${body.target_currency}`,
              unit_amount: {
                currency_code: body.source_currency,
                value: netSend,
              },
              quantity: "1",
              category: "DIGITAL_GOODS",
            },
          ],
        },
      ],
      application_context: {
        brand_name: "Veltro Global Payments",
        locale: "en-US",
        landing_page: "BILLING",
        shipping_preference: "NO_SHIPPING",
        user_action: "PAY_NOW",
        return_url: "https://veltro.app/payments/return",
        cancel_url: "https://veltro.app/payments/cancel",
      },
    };

    const orderRes = await fetch(`${baseUrl}/v2/checkout/orders`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json",
        "PayPal-Request-Id": requestId,
      },
      body: JSON.stringify(orderPayload),
    });

    const orderData = await orderRes.json();
    if (!orderRes.ok) {
      return new Response(
        JSON.stringify({
          error_code: "ERR_PAYPAL_ORDER_CREATION",
          domain: "ERR_DOMAIN_PAYPAL",
          message: orderData.message || "PayPal rejected order creation request.",
          technical_details: orderData,
        }),
        { status: orderRes.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const approveLink = orderData.links?.find((l: { rel: string }) => l.rel === "approve")?.href;

    // 4. Record transaction in Supabase
    await supabaseClient.from("transactions").insert({
      user_id: user.id,
      paypal_order_id: orderData.id,
      sender_email: user.email,
      recipient_identifier: body.recipient_identifier,
      source_currency: body.source_currency,
      target_currency: body.target_currency,
      send_amount: body.send_amount,
      fee_amount: baseFee,
      exchange_rate: 1.0, // Mid-market indexed
      recipient_amount: parseFloat(netSend),
      payment_method: "PAYPAL_SANDBOX",
      status: "CREATED",
      metadata: { request_id: requestId, links: orderData.links },
    });

    return new Response(
      JSON.stringify({
        order_id: orderData.id,
        status: orderData.status,
        approval_url: approveLink,
        request_id: requestId,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error_code: "ERR_SERVER_EXCEPTION",
        domain: "ERR_DOMAIN_NETWORK",
        message: "An unhandled exception occurred in order creation.",
        technical_details: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
