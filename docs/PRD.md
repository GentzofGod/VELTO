# Product Requirements Document (PRD)

## Veltro — Intelligent Global Payments & Anti-Scam Platform

**Document Version:** 1.0.0  
**Project Status:** Active Development  
**Hackathon Target:** PayPal AI Hackathon 2026 (Devpost)  
**Target Tracks:** Overall Grand Prize, Best Use of PayPal + AI, Best Use of Agentic Commerce, Most Impactful  
**Tagline:** Move money smarter. Stay one step ahead.

---

## 1. Executive Summary

Cross-border payments remain fraught with hidden foreign exchange margins, confusing fee schedules, settlement delays, and an alarming surge in sophisticated payment fraud. As artificial intelligence transforms commerce, bad actors deploy automated phishing, fabricated payment proofs, altered invoices, and social-engineering scams that target individuals, remote freelancers, cross-border businesses, and digital creators.

Veltro is an AI-powered international payment orchestration and threat-mitigation platform. It combines three complementary capabilities:
1. **Smart Payments Engine:** Transparent calculation, fee comparison, and execution of cross-border transfers powered by PayPal APIs and live foreign exchange indexes.
2. **WisePilot Financial AI Assistant:** An agentic financial co-pilot capable of autonomous tool execution for route discovery, fee computation, country compliance lookups, and transaction tracking.
3. **Veltro Shield Anti-Scam Protection:** A multi-modal risk-intelligence engine that analyzes suspicious messages, fake payment confirmations, untrusted URLs, and tampered invoices before money is transferred or goods are released.

---

## 2. Hackathon Alignment & Competitive Edge

### 2.1 PayPal AI Hackathon Criteria Alignment
* **Technological Implementation:** Deep integration of the PayPal Developer Platform (Orders v2 API, Payouts v1 API, Webhooks, Transaction Search) coupled with advanced AI reasoning (Gemini function-calling agents, multi-modal OCR inspection, and security threat heuristics).
* **Agentic Commerce Focus:** WisePilot does not just answer chat queries; it operates as an authorized agent with defined function tools, validating user intent, calculating real costs, and preparing structured PayPal payment payloads requiring explicit human authorization.
* **Design & Experience:** Modern, clean, responsive Flutter interface utilizing standard Material Design system icons. Strictly zero emojis and zero low-quality assets.
* **Impact & Novelty:** Solves the core trust barrier in global commerce. Rather than treating security as an afterthought or post-facto chargeback dispute, Veltro Shield provides pre-transaction risk mitigation.

---

## 3. User Personas & Problem Scenarios

### Persona A: The Global Freelancer / Remote Contractor
* **Profile:** Independent software engineer or designer receiving payments from international clients across North America, Europe, and Asia.
* **Pain Point:** Frequently targets of fake payment receipts ("Payment sent, please release deliverables") or overpayment chargeback schemes.
* **Veltro Solution:** Uploads client screenshots or invoices to Veltro Shield. The system warns if a screenshot lacks cryptographic or provider validation, checks official PayPal ledger status via API, and flags discrepancy in sender details.

### Persona B: Cross-Border Family Remitter
* **Profile:** Migrant worker or expatriate regularly sending funds home to family members overseas.
* **Pain Point:** Confused by opaque intermediary bank fees, remittance fees, and dynamic FX margins.
* **Veltro Solution:** Asks WisePilot in plain language: "What is the most cost-effective method to deliver $300 USD to a recipient in the Philippines?" WisePilot computes gross vs. net amounts and allows checkout via PayPal.

### Persona C: Small Online Merchant / Digital Creator
* **Profile:** Boutique seller accepting international custom commissions.
* **Pain Point:** Inbound emails with spoofed payment confirmation links leading to credential-harvesting phishing domains.
* **Veltro Solution:** Submits suspicious message text and embedded hyperlinks into Veltro Shield. Domain reputation analysis and NLP urgency detection trigger high-risk alert before credentials or goods are compromised.

---

## 4. System Capabilities & Functional Requirements

### 4.1 Module 1: Veltro Home (Unified Dashboard)
* **Account Overview:** Current balance, active currency wallets, and recent settlement logs.
* **Live Exchange Rate Matrix:** Real-time mid-market rates for key global pairs (USD, EUR, GBP, CAD, NGN, INR, PHP, JPY) with transparent spread breakdowns.
* **Security Status Card:** Summary of recent Veltro Shield inspections, active security advisories, and risk flags.
* **Quick Action Trays:** Instant navigation to "Send Money via PayPal", "Analyze Suspicious Payment", "Ask WisePilot", and "Verify Receipt".

### 4.2 Module 2: Global Payments Engine
* **Corridor Calculation:** Dynamic calculation of sending amount, exchange rate markup, fixed platform fees, variable processing fees, recipient currency payout, and estimated time of arrival.
* **Route Comparison:** Side-by-side comparison between PayPal account transfer, card-funded PayPal checkout, and alternative cross-border rails.
* **PayPal Sandbox Checkout:** Generation of compliant PayPal Order requests with breakdown parameters, client capture flows, and sandbox testing credentials.
* **Explicit Authorization Barrier:** Mandatory human-in-the-loop confirmation modal displaying recipient identity, gross send amount, net payout, and fees prior to API execution.

### 4.3 Module 3: WisePilot AI Payment Assistant
* **Natural Language Understanding:** Context-aware conversations regarding transfer regulations, currency trends, fee schedules, and transaction debugging.
* **Agentic Function Calling Tools:**
  * `calculate_transfer_fee(source_currency, target_currency, amount)`
  * `compare_payment_routes(source_currency, target_currency, amount)`
  * `check_country_payout_support(country_code, method)`
  * `query_paypal_transaction_status(transaction_id)`
  * `inspect_suspicious_payload(payload_type, raw_content)`
* **Guardrail Enforcement:** The agent cannot autonomously transfer funds without surfacing a signed confirmation sheet to the user.

### 4.4 Module 4: Veltro Shield (Anti-Scam Protection)
* **Suspicious Message Analyzer:**
  * Detects social engineering patterns: manufactured urgency ("Pay within 30 minutes or account suspended"), unauthorized escrow claims, off-platform payment redirection, and impersonation.
  * Outputs risk score, primary indicators, and actionable safety protocols.
* **Payment Receipt & Screenshot Verification:**
  * Multi-modal visual inspection of payment screenshots.
  * Checks for common forgery artifacts: font mismatches, irregular alignment, fabricated confirmation IDs, missing platform standard headers.
  * Enforces core rule: "Screenshots are informational only and never count as settlement proof. Verification requires direct API provider status."
* **Suspicious Link & Phishing URL Inspector:**
  * Evaluates submitted URLs against known phishing patterns, typosquatting domains (e.g., `paypa1-security.com`), suspicious top-level domains, and redirects.
* **Invoice & Billing Verification:**
  * Cross-references invoice payee details with historical verified accounts. Flags altered bank/PayPal IDs, abrupt account changes, or mismatching addresses.
* **Scam Education & Threat Repository:**
  * Searchable catalog of contemporary payment scams (Overpayment scam, Advance fee fraud, Fake supplier business email compromise, Bogus dispute blackmail).
* **Incident Reporting:**
  * Allows users to archive suspected threats, contributing to local threat signatures and exporting audit reports.

### 4.5 Module 5: Transaction Centre & Audit
* **Provider-Verified Ledger:** Real-time synchronization with PayPal Sandbox API to confirm status: `CREATED`, `APPROVED`, `COMPLETED`, `FAILED`, `DENIED`.
* **Receipt Detail Inspector:** Full cryptographic and API transaction IDs, timestamps, exchange rates applied, and recipient delivery confirmations.
* **Dispute Preparation Assistant:** Compiles verified timestamps, messages, and transaction records into structured summaries for customer support or dispute escalation.

---

## 5. Security, Governance, and Ethical Principles

1. **Objective Risk Indicators, Not Defamation:** Findings are categorized as probabilistic risk indicators (e.g., "High Risk of Domain Spoofing") rather than asserting legal culpability ("This user is a scammer").
2. **Never Treat Visual Proof as Financial Reality:** Receipts, push notifications, and emails can be forged within seconds. The platform strictly instructs users to confirm balance updates through provider APIs or native financial accounts.
3. **Mandatory Human-in-the-Loop:** Even if WisePilot crafts a payment payload, execution requires an explicit biometric or credential confirmation by the authenticated user.
4. **Data Privacy in Security Scanning:** Sensitive PII (card numbers, passwords, national identifiers) uploaded during scan operations is sanitized in client memory before analysis.

---

## 6. Non-Functional Requirements & Design Principles

* **Iconography & Asset Standards:**
  * Strictly no emojis anywhere in the user interface, documentation, or notifications.
  * Standardized icon libraries only (Google Material Symbols / Icons, Lucide vector icons).
  * Crisp vector assets at native DPI; zero rasterized or low-quality SVG artwork.
* **Resilience & Fault Tolerance:**
  * Strictly no silent fallbacks. If an external API, Supabase call, or LLM agent fails, the system must not degrade silently to fake dummy data.
  * Explicit error reporting with machine-readable error codes, human-friendly remediation guidance, and structured retrial controls (exponential backoff with jitter and explicit manual retry triggers).
* **Performance:**
  * AI analysis response latency <= 2.5 seconds for text evaluations.
  * Flutter web and mobile bundle optimized for instantaneous render with skeleton loaders.

---

## 7. MVP Scope for Hackathon Submission

1. Full responsive Flutter frontend supporting Web and Mobile viewports.
2. Supabase backend with authentication, database schema, and Row-Level Security (RLS).
3. Integrated PayPal Developer Sandbox:
   * Order creation and client approval capture.
   * Transaction lookup and verification.
4. Gemini-powered WisePilot Assistant with structured tool-calling.
5. Functional Veltro Shield suite:
   * Text message analysis.
   * Phishing URL scanner.
   * Invoice / Receipt metadata and visual anomaly inspector.
   * Structured risk tier presentation (`Low`, `Medium`, `High`, `Critical`).
6. End-to-end resilient architecture with explicit error handlers and retrial mechanisms.
