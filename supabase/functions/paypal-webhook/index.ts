// Supabase Edge Function: paypal-webhook
// Path: supabase/functions/paypal-webhook/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const rawBody = await req.text();
    const headers = req.headers;

    const authAlgo = headers.get("PAYPAL-AUTH-ALGO");
    const certUrl = headers.get("PAYPAL-CERT-URL");
    const transmissionId = headers.get("PAYPAL-TRANSMISSION-ID");
    const transmissionSig = headers.get("PAYPAL-TRANSMISSION-SIG");
    const transmissionTime = headers.get("PAYPAL-TRANSMISSION-TIME");
    const webhookId = Deno.env.get("PAYPAL_WEBHOOK_ID");

    const clientId = Deno.env.get("PAYPAL_SANDBOX_CLIENT_ID");
    const clientSecret = Deno.env.get("PAYPAL_SANDBOX_CLIENT_SECRET");
    const baseUrl = Deno.env.get("PAYPAL_API_BASE_URL") || "https://api-m.sandbox.paypal.com";

    // 1. Authenticate with PayPal
    const basicAuth = btoa(`${clientId}:${clientSecret}`);
    const tokenRes = await fetch(`${baseUrl}/v1/oauth2/token`, {
      method: "POST",
      headers: {
        "Authorization": `Basic ${basicAuth}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: "grant_type=client_credentials",
    });

    const { access_token } = await tokenRes.json();
    const eventPayload = JSON.parse(rawBody);

    // 2. Verify Webhook Signature via PayPal API
    const verifyRes = await fetch(`${baseUrl}/v1/notifications/verify-webhook-signature`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${access_token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        auth_algo: authAlgo,
        cert_url: certUrl,
        transmission_id: transmissionId,
        transmission_sig: transmissionSig,
        transmission_time: transmissionTime,
        webhook_id: webhookId,
        webhook_event: eventPayload,
      }),
    });

    const verifyData = await verifyRes.json();
    if (verifyData.verification_status !== "SUCCESS") {
      console.error("Webhook signature verification failed:", verifyData);
      return new Response("Invalid signature", { status: 400 });
    }

    // 3. Process Verified Webhook Event
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const eventType = eventPayload.event_type;
    const resource = eventPayload.resource;

    if (eventType === "PAYMENT.CAPTURE.COMPLETED") {
      const orderId = resource.supplementary_data?.related_ids?.order_id;
      if (orderId) {
        await supabaseClient
          .from("transactions")
          .update({
            status: "COMPLETED",
            paypal_capture_id: resource.id,
            updated_at: new Date().toISOString(),
          })
          .eq("paypal_order_id", orderId);
      }
    }

    // Log to Audit Ledger
    await supabaseClient.from("audit_logs").insert({
      action_type: `WEBHOOK_${eventType}`,
      entity_id: resource?.id,
      details: {
        event_id: eventPayload.id,
        summary: eventPayload.summary,
        status: resource?.status,
      },
    });

    return new Response(JSON.stringify({ status: "EVENT_PROCESSED" }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Webhook processing error:", error);
    return new Response("Webhook handler error", { status: 500 });
  }
});
