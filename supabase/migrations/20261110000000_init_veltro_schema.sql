-- Veltro Database Schema
-- Migration: 20261110000000_init_veltro_schema.sql
-- Description: Core tables for profiles, transactions, shield security scans, incident reports, and audit logs.

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    default_currency VARCHAR(3) DEFAULT 'USD',
    risk_tolerance_level TEXT DEFAULT 'BALANCED',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Transactions Table (PayPal synchronized)
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    paypal_order_id TEXT UNIQUE,
    paypal_capture_id TEXT UNIQUE,
    sender_email TEXT NOT NULL,
    recipient_identifier TEXT NOT NULL,
    source_currency VARCHAR(3) NOT NULL,
    target_currency VARCHAR(3) NOT NULL,
    send_amount NUMERIC(12, 2) NOT NULL,
    fee_amount NUMERIC(12, 2) NOT NULL,
    exchange_rate NUMERIC(12, 6) NOT NULL,
    recipient_amount NUMERIC(12, 2) NOT NULL,
    payment_method TEXT NOT NULL DEFAULT 'PAYPAL_SANDBOX',
    status TEXT NOT NULL DEFAULT 'PENDING', -- 'PENDING', 'CREATED', 'APPROVED', 'COMPLETED', 'FAILED', 'DENIED'
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Veltro Shield Security Scans Table
CREATE TABLE IF NOT EXISTS public.shield_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    scan_type TEXT NOT NULL, -- 'MESSAGE', 'LINK', 'RECEIPT', 'INVOICE'
    input_payload TEXT NOT NULL,
    evidence_file_url TEXT,
    risk_level TEXT NOT NULL, -- 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
    confidence_score NUMERIC(5, 2) NOT NULL,
    summary TEXT NOT NULL,
    detected_indicators JSONB NOT NULL DEFAULT '[]'::jsonb,
    recommended_actions JSONB NOT NULL DEFAULT '[]'::jsonb,
    raw_ai_analysis JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Incident Reports Table
CREATE TABLE IF NOT EXISTS public.incident_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    scan_id UUID REFERENCES public.shield_scans(id) ON DELETE SET NULL,
    report_title TEXT NOT NULL,
    threat_category TEXT NOT NULL, -- 'PHISHING', 'FAKE_RECEIPT', 'OVERPAYMENT', 'IMPERSONATION'
    incident_details TEXT NOT NULL,
    status TEXT DEFAULT 'OPEN', -- 'OPEN', 'UNDER_REVIEW', 'RESOLVED'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Audit Log Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action_type TEXT NOT NULL,
    entity_id TEXT,
    ip_address INET,
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for Query Performance
CREATE INDEX IF NOT EXISTS idx_transactions_user ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_order ON public.transactions(paypal_order_id);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON public.transactions(status);
CREATE INDEX IF NOT EXISTS idx_shield_scans_user ON public.shield_scans(user_id);
CREATE INDEX IF NOT EXISTS idx_shield_scans_risk ON public.shield_scans(risk_level);
CREATE INDEX IF NOT EXISTS idx_incident_reports_user ON public.incident_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON public.audit_logs(user_id);

-- Row Level Security (RLS) Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shield_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.incident_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Transactions Policies
CREATE POLICY "Users can view own transactions"
    ON public.transactions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own transactions"
    ON public.transactions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own transactions"
    ON public.transactions FOR UPDATE
    USING (auth.uid() = user_id);

-- Shield Scans Policies
CREATE POLICY "Users can view own shield scans"
    ON public.shield_scans FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own shield scans"
    ON public.shield_scans FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Incident Reports Policies
CREATE POLICY "Users can view own incident reports"
    ON public.incident_reports FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own incident reports"
    ON public.incident_reports FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Audit Logs Policies
CREATE POLICY "Users can view own audit logs"
    ON public.audit_logs FOR SELECT
    USING (auth.uid() = user_id);
