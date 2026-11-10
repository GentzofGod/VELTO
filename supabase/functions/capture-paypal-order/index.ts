// Supabase Edge Function: capture-paypal-order
// Path: supabase/functions/capture-paypal-order/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, paypal-request-id",
};

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

    const { order_id } = await req.json();
    if (!order_id) {
      return new Response(
        JSON.stringify({
          error_code: "ERR_VAL_MISSING_ORDER_ID",
          domain: "ERR_DOMAIN_VALIDATION",
          message: "Order ID is required for capture.",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const clientId = Deno.env.get("PAYPAL_SANDBOX_CLIENT_ID");
    const clientSecret = Deno.env.get("PAYPAL_SANDBOX_CLIENT_SECRET");
    const baseUrl = Deno.env.get("PAYPAL_API_BASE_URL") || "https://api-m.sandbox.paypal.com";

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
      return new Response(
        JSON.stringify({
          error_code: "ERR_PAYPAL_AUTH",
          domain: "ERR_DOMAIN_PAYPAL",
          message: "Failed to authenticate with PayPal Sandbox for capture.",
        }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const tokenData = await tokenRes.json();
    const accessToken = tokenData.access_token;

    // 2. Capture Order via PayPal Orders v2 API
    const captureRes = await fetch(`${baseUrl}/v2/checkout/orders/${order_id}/capture`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
    });

    const captureData = await captureRes.json();
    if (!captureRes.ok) {
      return new Response(
        JSON.stringify({
          error_code: "ERR_PAYPAL_CAPTURE_FAILED",
          domain: "ERR_DOMAIN_PAYPAL",
          message: captureData.message || "PayPal rejected payment capture.",
          technical_details: captureData,
        }),
        { status: captureRes.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const captureId = captureData.purchase_units?.[0]?.payments?.captures?.[0]?.id;
    const finalStatus = captureData.status; // Typically "COMPLETED"

    // 3. Update transaction record in Supabase
    await supabaseClient
      .from("transactions")
      .update({
        paypal_capture_id: captureId,
        status: finalStatus,
        updated_at: new Date().toISOString(),
      })
      .eq("paypal_order_id", order_id)
      .eq("user_id", user.id);

    return new Response(
      JSON.stringify({
        order_id: order_id,
        capture_id: captureId,
        status: finalStatus,
        payer: captureData.payer,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error_code: "ERR_SERVER_EXCEPTION",
        domain: "ERR_DOMAIN_NETWORK",
        message: "An unhandled exception occurred in payment capture.",
        technical_details: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
