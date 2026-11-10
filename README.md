# Veltro — Intelligent Global Payments & Anti-Scam Platform

**Tagline:** Move money smarter. Stay one step ahead.  
**Submission For:** PayPal AI Hackathon 2026 (Devpost)  
**Target Award Categories:** Best Use of PayPal + AI ($5,000), Best Use of Agentic Commerce ($5,000), Most Impactful ($5,000), Overall Grand Prize

---

## 1. Overview

Veltro is an AI-powered international payment orchestration and threat mitigation platform. It is engineered to solve the twin challenges of global financial interaction:
1. **Complexity and friction in cross-border payments:** Unclear foreign exchange margins, complex routing choices, and fluctuating fee structures.
2. **The rapid surge of cross-border payment fraud:** Manipulated digital receipts, deceptive phishing links, forged invoices, and social-engineering scams that exploit freelancers, small businesses, and cross-border remitters.

Veltro introduces an active security paradigm: combining an intelligent financial agent (**WisePilot**) with an AI-driven threat mitigation shield (**Veltro Shield**) and direct **PayPal Sandbox** execution.

---

## 2. Core Capabilities

### 2.1 Smart Payments Engine
* **Dynamic Fee & Corridor Calculator:** Computes exact sending costs, mid-market exchange rates, platform fees, and recipient delivery totals across international corridors (e.g., USD, EUR, GBP, KES, NGN, INR, PHP).
* **Payment Route Comparison:** Side-by-side comparison of delivery time, total fee percentage, and net recipient yield.
* **PayPal Sandbox Integration:** Direct order creation, client approval capture, and real-time transaction synchronization via PayPal Orders v2 API.

### 2.2 WisePilot — Agentic Financial Assistant
* **Natural Language Guidance:** Allows users to query complex cross-border corridors, understand regulatory requirements, and estimate payment timelines.
* **Autonomous Tool Calling:** Equipped with specialized function tools to query exchange rates, compute corridor fee breakdowns, check country availability, and trigger threat assessments.
* **Human-in-the-Loop Guardrail:** WisePilot prepares transaction proposals but cannot autonomously execute money movement. Financial execution requires explicit human authorization on a verified confirmation sheet.

### 2.3 Veltro Shield — Anti-Scam Security Layer (Core Differentiator)
* **Suspicious Message & Email Detection:** Analyzes conversational text for social engineering markers, overpayment claims, unauthorized escrow promises, and urgency tactics.
* **Fake Payment Confirmation Inspection:** Multi-modal analysis of uploaded payment screenshots and digital receipts to detect visual tampering, font inconsistencies, and alignment artifacts.
* **The "Zero Trust in Screenshots" Invariant:** Screenshots are explicitly treated as informational only. Legitimate receipt of funds must be verified through provider APIs.
* **Suspicious Link & Phishing Analysis:** Evaluates URLs against typosquatting heuristics, disposable top-level domains, and malicious redirect chains.
* **Invoice Verification:** Validates invoice payee details, flags abrupt account changes, and detects Business Email Compromise (BEC) patterns.
* **Standardized Risk Assessment:** Categorizes all inspections into four distinct tiers: `LOW`, `MEDIUM`, `HIGH`, or `CRITICAL`, accompanied by actionable next steps.
* **Scam Education & Incident Archive:** Searchable catalog of common international payment scams and personal incident logging.

### 2.4 Transaction Centre & Audit
* **Provider-Verified Ledger:** Synchronizes live status directly with PayPal Sandbox (`CREATED`, `APPROVED`, `COMPLETED`, `DENIED`).
* **Cryptographic Event Auditing:** Verifies incoming PayPal Webhook signatures to ensure tamper-proof event logs.
* **Dispute Preparation Assistant:** Compiles verified timestamps, messages, and transaction records into structured documentation for dispute resolution.

---

## 3. PayPal AI Hackathon Alignment

| Hackathon Criterion | Veltro Implementation |
| :--- | :--- |
| **Technological Implementation** | Comprehensive use of the PayPal Developer Platform (OAuth 2.0, Orders v2 API, Payouts v1 API, Webhooks, Transaction Status Lookup) coupled with Gemini multi-modal AI reasoning. |
| **Agentic Commerce** | WisePilot operates as an autonomous agent equipped with structured function calling to calculate fees, validate routes, and construct compliant payment payloads. |
| **Design & Coherence** | Complete, production-grade Flutter application built with clean architecture, responsive layouts, and standard Google Material Symbols. Strictly zero emojis or low-quality assets. |
| **Potential Impact** | Solves the primary trust deficit in cross-border commerce by protecting digital freelancers and businesses from loss due to payment scams. |
| **Innovation & Originality** | Redefines payment interfaces by embedding pre-transaction fraud intelligence directly into the payment flow rather than relying on reactive post-dispute claims. |

---

## 4. Architectural Rules & Standards

1. **Iconography Standard:**
   * Strictly standard vector icons only (Google Material Symbols / Icons, Lucide vector assets).
   * Complete prohibition of emojis across user interfaces, alerts, notifications, and technical documentation.
2. **Zero Silent Fallback Policy:**
   * The platform never falls back to dummy data, synthetic estimates, or ambiguous error suppression.
   * If a service or API is unavailable, the system reports the specific error domain, code, and debugging reference, providing immediate automated or manual retrial options.
3. **Verification Invariant:**
   * Visual receipts or screenshots are never treated as proof of settlement. All payment confirmations require direct API queries to PayPal.

---

## 5. Technology Stack

* **Frontend:** Flutter Web & Mobile (Dart 3.x), Riverpod state management, Clean Architecture.
* **Backend:** Supabase (PostgreSQL 15+, Row-Level Security, Edge Functions in Deno/TypeScript).
* **AI Intelligence:** Google Gemini 1.5 Pro / Flash (structured JSON output, function calling, vision inspection).
* **Payment Rails:** PayPal Developer Platform Sandbox (Orders v2, Payouts v1, Webhook Verification).
* **Security & Reputation:** Custom heuristic domain analyzer and multi-modal anomaly detector.

---

## 6. Project Structure

```
VELTO/
|-- docs/
|   |-- PRD.md                         # Product Requirements Document
|   |-- SYSTEM_ARCHITECTURE.md         # System Architecture & Component Design
|   |-- VELTRO_SHIELD_SPEC.md          # Anti-Scam Security Specification & Heuristics
|   |-- PAYPAL_INTEGRATION_SPEC.md     # PayPal API, Orders, Payouts & Webhook Specs
|   \-- ERROR_HANDLING_AND_RETRIAL.md  # Resilience, Error Taxonomy & Retrial Protocol
|-- README.md                          # Repository Documentation & Overview
\-- LICENSE                            # Open Source License (MIT / Apache-2.0)
```

---

## 7. Setup & Getting Started

### 7.1 Prerequisites
* Flutter SDK (Version 3.22 or higher)
* Dart SDK (Version 3.4 or higher)
* Supabase Account & Project
* PayPal Developer Account (Sandbox credentials)
* Gemini API Key

### 7.2 Environment Configuration
Create a `.env` file in the project root:

```ini
# PayPal Developer Sandbox
PAYPAL_SANDBOX_CLIENT_ID=your_paypal_client_id
PAYPAL_SANDBOX_CLIENT_SECRET=your_paypal_client_secret
PAYPAL_API_BASE_URL=https://api-m.sandbox.paypal.com

# Supabase Backend
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# AI Intelligence
GEMINI_API_KEY=your_gemini_api_key
```

### 7.3 Installation & Execution
```bash
# Clone the repository
git clone https://github.com/your-org/veltro.git
cd veltro

# Install Flutter dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Run on connected Mobile device (iOS / Android)
flutter run
```

---

## 8. Devpost Submission Checklist

* [x] **Project Repository:** Public repository containing full source code and setup instructions.
* [x] **Open Source License:** License visible in repository root.
* [x] **Meaningful PayPal Integration:** Real-time PayPal Sandbox order creation, capture, and status queries.
* [x] **Meaningful AI Integration:** Gemini function-calling agent (WisePilot) and multi-modal fraud detection (Veltro Shield).
* [x] **Functional Demo:** Interactive runnable build with explicit error handling and retrial workflows.
* [x] **Demo Video:** Under 3 minutes showcasing end-to-end payment guidance, scam detection, and PayPal Sandbox checkout.
