# PayPal AI Hackathon 2026 — Submission & Demo Guide

**Project Name:** Veltro — Intelligent Global Payments & Anti-Scam Platform  
**Tagline:** Move money smarter. Stay one step ahead.  
**Target Award Tracks:**
* Best Use of PayPal + AI ($5,000)
* Best Use of Agentic Commerce ($5,000)
* Most Impactful Project ($5,000)
* Overall Hackathon Grand Prize

---

## 1. Devpost Submission Questionnaire Copy

### 1.1 Inspiration
Every year, hundreds of billions of dollars move across international borders via freelancers, digital creators, remote agencies, and family remitters. Yet, cross-border financial movement remains burdened by two distinct obstacles:
1. **Opaque Pricing & Fragmentation:** Hidden foreign exchange markups, variable routing fees, and confusing settlement delays.
2. **The Global Payment Fraud Wave:** A dramatic surge in AI-generated phishing links, altered supplier invoices, and doctored payment screenshots ("Payment sent, release the deliverables immediately").

We asked: *What happens when you combine an agentic financial co-pilot with an active threat-mitigation shield and direct PayPal Sandbox rails?*  
The result is **Veltro** — an intelligent financial assistant designed to make sending money transparent and potentially dangerous financial decisions harder to make accidentally.

---

### 1.2 What It Does
Veltro unites three complementary capabilities into a single, cohesive experience:
* **WisePilot Financial Assistant:** An agentic AI advisor that understands natural-language financial queries, executes deterministic calculation tools, compares international routes, and structures compliant payment proposals.
* **Veltro Shield Security Suite:** An active pre-transaction security layer that analyzes suspicious messages, verifies payment receipts by cross-referencing the PayPal Sandbox API, inspects typosquatting links, and categorizes threats into four clear risk tiers (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`).
* **Global Payments & Transaction Centre:** Direct PayPal Orders v2 and Payouts v1 integration with transparent corridor fee breakdowns, mandatory human-in-the-loop authorization, cryptographic webhook verification, and chronological tracking timelines.

---

### 1.3 How We Built It
* **Frontend:** Flutter 3.x engineered for responsive cross-platform execution (Web, Mobile, Desktop). Built with Clean Architecture, standard Google Material Symbols, and zero emojis.
* **Backend:** Supabase PostgreSQL transactional database with Row-Level Security (RLS) policies, JWT authentication, and Deno/TypeScript Edge Functions.
* **AI Engine:** Google Gemini 1.5 Pro and Flash with structured tool declarations, function calling, and zero-shot multi-modal risk classification.
* **Payment Rails:** PayPal Developer Platform Sandbox utilizing OAuth 2.0 Client Credentials, Orders v2 API (`/v2/checkout/orders`), Payouts v1 API, and cryptographic Webhook signature verification (`verify-webhook-signature`).
* **Resilience Doctrine:** A strict **Zero Silent Fallback** standard where all errors surface transparently with machine codes, human guidance, and automated jittered backoff retrials.

---

### 1.4 Challenges We Ran Into
* **The "Zero Trust in Screenshots" Invariant:** Digital receipts can be fabricated in seconds. We architected Veltro Shield to enforce that visual receipts are strictly informational; legitimate settlement must be validated through direct provider API queries.
* **Agentic Guardrails:** AI models should provide advice, not execute unilateral money movements. We established an architectural barrier requiring explicit human authorization with unskippable verification before any PayPal API mutation executes.
* **Eliminating Silent Fallbacks:** Ensuring that network timeouts or API errors never degrade into synthetic guesses or default rates, preserving data integrity and user trust.

---

### 1.5 Accomplishments That We're Proud Of
* Fully functional end-to-end integration combining PayPal Developer Sandbox, Gemini tool calling, and multi-modal fraud detection.
* 100% automated test pass rate covering desktop viewports, mobile viewports, service integrations, and retrial controllers.
* A clean, distraction-free fintech interface using deep navy, emerald green, and standard vector symbols.

---

### 1.6 What We Learned
* The critical importance of pre-transaction fraud prevention in agentic commerce. Trust is the primary constraint holding back autonomous financial workflows.
* How to leverage PayPal idempotency headers (`PayPal-Request-Id`) to guarantee safe automated retrials during transient network drops.

---

### 1.7 What's Next for Veltro
* Incorporating live enterprise remittance corridors for sub-Saharan African bank payouts.
* Advanced invoice biometric OCR matching against verified vendor public keys.
* Automated dispute file compilation exported directly into the PayPal Resolution Center API.

---

## 2. Under 3-Minute Video Pitch Script

**Target Duration:** 2 minutes, 45 seconds  
**Visual Strategy:** Screen recording of Flutter Web and Mobile interface with clean voiceover.

### Segment 1: The Hook & Global Problem (0:00 - 0:30)
> *"Cross-border payments are the lifeblood of the global digital economy. But whether you are a freelancer in Nairobi or an online business in London, international payments remain confusing and dangerous. Hidden FX margins eat your earnings, while fake payment receipts, altered invoices, and phishing scams steal millions every month.*  
> *Meet Veltro: the intelligent international payments and anti-scam platform powered by PayPal and AI."*

### Segment 2: WisePilot Financial Co-Pilot (0:30 - 1:10)
> *(Screen: Opens WisePilot AI tab)*  
> *"Instead of navigating confusing fee charts, users talk directly to WisePilot, our agentic payment co-pilot. Watch what happens when I ask: 'How much does it cost to send $250 USD to Kenya?'*  
> *(Types prompt)*  
> *WisePilot does not return generic text. It calls specialized calculation tools, computes real-time FX spreads, compares PayPal Sandbox with legacy wire rails, and returns an actionable structured card. WisePilot guides, but never moves money without human control."*

### Segment 3: Veltro Shield Live Threat Inspection (1:10 - 1:55)
> *(Screen: Switches to Veltro Shield tab)*  
> *"Now let's examine Veltro's core differentiator: Veltro Shield.*  
> *A freelancer receives an email claiming: 'I sent $500 by accident. Please wire back the $200 extra urgently.'*  
> *(Pastes text into Message Scanner and clicks Analyze)*  
> *Within milliseconds, Veltro Shield flags a Critical Threat: identifying manufactured urgency and overpayment fraud indicators.*  
> *Even more powerful is our Receipt Verifier. When a buyer sends a doctored screenshot with a fabricated transaction ID, Veltro Shield queries the PayPal Sandbox API directly. Because the ID does not exist in the official ledger, Shield alerts the user: 'Screenshot is fabricated. Do not release work.'*  
> *Our core rule: Screenshots are never proof of funds arrival; authentic confirmation requires provider API verification."*

### Segment 4: Global Payments & PayPal Sandbox Checkout (1:55 - 2:35)
> *(Screen: Switches to Payments tab)*  
> *"In the Global Payments Hub, users calculate corridors, compare fees, and select PayPal Sandbox for instant settlement.*  
> *Before any funds move, Veltro requires an explicit confirmation modal. Once authorized, the transaction captures in real-time, stores in our Supabase PostgreSQL ledger, and updates the Transaction Centre with an immutable chronological timeline.*  
> *Notice our negative testing switch: if an issuer declines a payment, Veltro adheres to our Zero Silent Fallback policy, displaying the exact PayPal error code and offering structured retrial options."*

### Segment 5: Summary & Impact (2:35 - 2:55)
> *"Veltro combines the global settlement power of PayPal with the reasoning of modern AI to make cross-border commerce faster, smarter, and scam-proof.*  
> *Move money smarter. Stay one step ahead.*  
> *Thank you."*

---

## 3. Judge Walkthrough & Verification Steps

Judges can run and verify the complete application locally using the instructions below:

### 3.1 Local Launch Instructions
```bash
# 1. Clone the repository
git clone https://github.com/your-org/veltro.git
cd veltro

# 2. Install dependencies
flutter pub get

# 3. Run all automated tests (desktop, mobile, services, retrials)
flutter test

# 4. Launch in Chrome
flutter run -d chrome
```

### 3.2 Pre-Configured Test Scenarios for Judges

| Step | Section | Action | Expected Result |
| :---: | :--- | :--- | :--- |
| **1** | **Home** | Toggle the visibility eye icon next to the welcome header. | Balances mask to `**** USD` and reveal cleanly. |
| **2** | **Payments** | Enter `$250.00 USD` to `KES`, click "Review & Pay with PayPal Sandbox". | Explicit confirmation sheet opens. Authorizing completes the transaction and adds it to the ledger. |
| **3** | **Payments (Negative Test)** | Toggle "Simulate PayPal Sandbox Card Decline", then click "Review & Pay". | Triggers explicit HTTP 422 `INSTRUMENT_DECLINED` error banner with active "Retry Operation" CTA. |
| **4** | **Shield** | Go to Receipt Verifier, click "Test Fabricated Fake Receipt". | Queries PayPal Sandbox API, returns 404, and flags receipt as `CRITICAL` threat. |
| **5** | **WisePilot** | Click suggestion chip "How much to send $180 USD to Nigeria?". | Returns structured fee breakdown card with net recipient NGN amount. |
| **6** | **Transactions** | Click on any transaction in the ledger. | Opens detail modal displaying the chronological tracking timeline and "Export Audit Dossier" action. |
