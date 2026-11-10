// Supabase Edge Function: verify-paypal-transaction
// Path: supabase/functions/verify-paypal-transaction/index.ts

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
    const { transaction_id } = await req.json();
    if (!transaction_id) {
      return new Response(
        JSON.stringify({
          error_code: "ERR_VAL_MISSING_ID",
          domain: "ERR_DOMAIN_VALIDATION",
          message: "Transaction ID is required for verification.",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const clientId = Deno.env.get("PAYPAL_SANDBOX_CLIENT_ID");
    const clientSecret = Deno.env.get("PAYPAL_SANDBOX_CLIENT_SECRET");
    const baseUrl = Deno.env.get("PAYPAL_API_BASE_URL") || "https://api-m.sandbox.paypal.com";

    // 1. Get OAuth Token
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
          message: "Failed to authenticate with PayPal Sandbox for transaction lookup.",
        }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const tokenData = await tokenRes.json();
    const accessToken = tokenData.access_token;

    // 2. Query PayPal API
    const lookupRes = await fetch(`${baseUrl}/v2/checkout/orders/${transaction_id}`, {
      method: "GET",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
    });

    if (lookupRes.status === 404) {
      // Transaction does NOT exist in PayPal Sandbox
      return new Response(
        JSON.stringify({
          verified: false,
          exists_in_ledger: false,
          provider: "PayPal Sandbox",
          transaction_id: transaction_id,
          message: "Transaction ID was not found in PayPal records. This may indicate a fabricated receipt.",
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!lookupRes.ok) {
      const errData = await lookupRes.json();
      return new Response(
        JSON.stringify({
          error_code: "ERR_PAYPAL_LOOKUP_FAILED",
          domain: "ERR_DOMAIN_PAYPAL",
          message: errData.message || "PayPal returned an error during status lookup.",
          technical_details: errData,
        }),
        { status: lookupRes.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const orderData = await lookupRes.json();
    const purchaseUnit = orderData.purchase_units?.[0];

    return new Response(
      JSON.stringify({
        verified: true,
        exists_in_ledger: true,
        provider: "PayPal Sandbox",
        transaction_id: orderData.id,
        status: orderData.status,
        amount: purchaseUnit?.amount?.value,
        currency: purchaseUnit?.amount?.currency_code,
        create_time: orderData.create_time,
        payer_email: orderData.payer?.email_address,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error_code: "ERR_SERVER_EXCEPTION",
        domain: "ERR_DOMAIN_NETWORK",
        message: "An unhandled exception occurred during transaction verification.",
        technical_details: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
