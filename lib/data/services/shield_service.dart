// Veltro Shield Threat Detection & Security Intelligence Service
// Path: lib/data/services/shield_service.dart

import '../models/shield_scan_model.dart';
import 'paypal_sandbox_service.dart';

class ScamArticle {
  final String id;
  final String title;
  final String category;
  final String summary;
  final List<String> redFlags;
  final List<String> preventionSteps;

  const ScamArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.redFlags,
    required this.preventionSteps,
  });
}

class ShieldService {
  static final ShieldService _instance = ShieldService._internal();
  factory ShieldService() => _instance;
  ShieldService._internal();

  final List<ShieldScanModel> _scanHistory = [];
  List<ShieldScanModel> get scanHistory => List.unmodifiable(_scanHistory);

  // Scam Knowledge Encyclopedia
  final List<ScamArticle> scamArticles = const [
    ScamArticle(
      id: 'scam_overpayment',
      title: 'The Overpayment & Accidental Refund Scheme',
      category: 'Marketplace & Freelance',
      summary: 'A buyer claims to have sent extra money by mistake and urgently asks you to wire back the difference before the original payment clears.',
      redFlags: [
        'Insistence on immediate refund via an irreversible method like crypto or wire.',
        'Buyer provides a doctored screenshot showing an inflated balance.',
        'Payment has not actually settled in your official PayPal account balance.',
      ],
      preventionSteps: [
        'Never refund funds until you have verified settlement in your official account.',
        'Issue refunds solely through the original platform refund mechanism.',
        'Never send cash or third-party money transfers to resolve overpayments.',
      ],
    ),
    ScamArticle(
      id: 'scam_fake_receipt',
      title: 'Fabricated Payment Proofs & Digital Screenshots',
      category: 'Invoicing & Sales',
      summary: 'Scammers generate convincing fake PayPal confirmation emails or app screenshots using web inspectors to induce sellers into releasing goods.',
      redFlags: [
        'Mismatched typography or misaligned fonts around the dollar amount.',
        'Transaction ID does not exist when queried through the PayPal API.',
        'Notification email sent from generic domains like @gmail.com or spoofed headers.',
      ],
      preventionSteps: [
        'Never treat a screenshot as proof of money arrival.',
        'Log in directly to your official payment provider portal to verify cleared funds.',
        'Require API-confirmed webhook or provider ledger status before shipment.',
      ],
    ),
    ScamArticle(
      id: 'scam_advance_fee',
      title: 'Advance Clearance Fee & Third-Party Courier Traps',
      category: 'International Transfers',
      summary: 'You are informed that a large payment is on hold until you pay an upfront clearance, customs, or courier insurance fee.',
      redFlags: [
        'Claims that PayPal requires a third-party courier deposit to release money.',
        'High-pressure deadlines warning of account suspension or police reports.',
        'Requests for payment via gift cards, wire transfers, or unverified wallets.',
      ],
      preventionSteps: [
        'PayPal does not hold funds contingent upon third-party courier payments.',
        'Cease communication immediately upon demands for upfront clearance deposits.',
      ],
    ),
    ScamArticle(
      id: 'scam_phishing_link',
      title: 'Typosquatting & Fake Resolution Center Links',
      category: 'Identity & Credentials',
      summary: 'Deceptive hyperlinks mimicking payment portals designed to capture login credentials, two-factor codes, or financial account details.',
      redFlags: [
        'Misspelled domain names (e.g., paypa1-verification.com, paypal-support.cc).',
        'Urgent warnings claiming your account is restricted or compromised.',
        'Non-standard top-level domains or multi-hop redirect URLs.',
      ],
      preventionSteps: [
        'Inspect URL domain roots carefully before entering credentials.',
        'Always access account resolution centers directly via bookmark or official app.',
      ],
    ),
  ];

  /// Evaluates suspicious text messages or email requests
  Future<ShieldScanModel> analyzeMessage(String text) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final lower = text.toLowerCase();
    final indicators = <RiskIndicator>[];
    RiskTier tier = RiskTier.low;
    double score = 0.15;

    // Check for urgency
    if (lower.contains('urgent') || lower.contains('immediately') || lower.contains('within 1 hour') || lower.contains('police') || lower.contains('suspended')) {
      indicators.add(const RiskIndicator(
        code: 'IND_MANUFACTURED_URGENCY',
        severity: 'MEDIUM',
        description: 'Message contains high-pressure psychological urgency tactics designed to bypass critical thinking.',
      ));
      score += 0.25;
    }

    // Check for overpayment cue
    if (lower.contains('overpaid') || lower.contains('extra') || lower.contains('send back') || lower.contains('refund difference')) {
      indicators.add(const RiskIndicator(
        code: 'IND_OVERPAYMENT_INDICATOR',
        severity: 'HIGH',
        description: 'Detected language consistent with overpayment refund scams.',
      ));
      score += 0.40;
    }

    // Check for off-platform payment redirection
    if (lower.contains('friends and family') || lower.contains('outside') || lower.contains('crypto') || lower.contains('gift card') || lower.contains('wire')) {
      indicators.add(const RiskIndicator(
        code: 'IND_OFF_PLATFORM_REDIRECTION',
        severity: 'HIGH',
        description: 'Request urges payment through non-reversible or off-platform payment channels.',
      ));
      score += 0.35;
    }

    // Check for fake courier / clearance fee
    if (lower.contains('courier') || lower.contains('clearance fee') || lower.contains('agent fee') || lower.contains('holding funds')) {
      indicators.add(const RiskIndicator(
        code: 'IND_FALSE_ESCROW_CLAIM',
        severity: 'CRITICAL',
        description: 'Claims funds are on hold pending third-party courier or clearance fees. PayPal does not operate this model.',
      ));
      score += 0.45;
    }

    if (score >= 0.75) {
      tier = RiskTier.critical;
    } else if (score >= 0.50) {
      tier = RiskTier.high;
    } else if (score >= 0.25) {
      tier = RiskTier.medium;
    }

    final scan = ShieldScanModel(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      scanType: ScanType.message,
      inputPayload: text,
      riskTier: tier,
      confidenceScore: score.clamp(0.1, 0.99),
      summary: tier == RiskTier.low
          ? 'No overt scam patterns detected in this message. Standard vigilance applies.'
          : 'High risk indicators detected. Communication exhibits patterns common to payment redirection and social engineering schemes.',
      indicators: indicators.isEmpty
          ? [
              const RiskIndicator(
                code: 'IND_STANDARD_TEXT',
                severity: 'LOW',
                description: 'Content exhibits standard commercial conversational patterns.',
              )
            ]
          : indicators,
      recommendedActions: tier == RiskTier.low
          ? ['Verify the sender identity and proceed through standard channels.']
          : [
              'Do not refund any money or send funds to third parties.',
              'Verify payment arrival by logging into your official PayPal portal directly.',
              'Do not click links or call phone numbers provided within the message.',
            ],
      timestamp: DateTime.now(),
    );

    _scanHistory.insert(0, scan);
    return scan;
  }

  /// Evaluates suspicious website links
  Future<ShieldScanModel> analyzeLink(String url) async {
    await Future.delayed(const Duration(milliseconds: 650));

    final cleanUrl = url.trim().toLowerCase();
    final indicators = <RiskIndicator>[];
    RiskTier tier = RiskTier.low;
    double score = 0.12;

    final isTyposquat = cleanUrl.contains('paypa1') ||
        cleanUrl.contains('paypal-verify') ||
        cleanUrl.contains('secure-paypal') ||
        cleanUrl.contains('account-update');

    final isSuspiciousTld = cleanUrl.endsWith('.xyz') ||
        cleanUrl.endsWith('.top') ||
        cleanUrl.endsWith('.cc') ||
        cleanUrl.endsWith('.tk') ||
        cleanUrl.endsWith('.ru');

    if (isTyposquat) {
      indicators.add(const RiskIndicator(
        code: 'IND_TYPOSQUATTING_DOMAIN',
        severity: 'CRITICAL',
        description: 'Domain closely mimics the PayPal brand name using deceptive character substitutions.',
      ));
      score += 0.65;
    }

    if (isSuspiciousTld) {
      indicators.add(const RiskIndicator(
        code: 'IND_HIGH_RISK_TLD',
        severity: 'HIGH',
        description: 'Destination uses a top-level domain frequently associated with transient phishing pages.',
      ));
      score += 0.30;
    }

    if (score >= 0.70) {
      tier = RiskTier.critical;
    } else if (score >= 0.40) {
      tier = RiskTier.high;
    } else if (score >= 0.20) {
      tier = RiskTier.medium;
    }

    final scan = ShieldScanModel(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      scanType: ScanType.link,
      inputPayload: url,
      riskTier: tier,
      confidenceScore: score.clamp(0.1, 0.99),
      summary: tier == RiskTier.low
          ? 'Domain matches standard registered patterns. No known threat signatures active.'
          : 'Elevated phishing probability. Domain name and characteristics indicate a spoofed destination.',
      indicators: indicators.isEmpty
          ? [
              const RiskIndicator(
                code: 'IND_CLEAN_DOMAIN',
                severity: 'LOW',
                description: 'Domain formatting conforms to standard commercial web protocols.',
              )
            ]
          : indicators,
      recommendedActions: tier == RiskTier.low
          ? ['Ensure connection uses HTTPS before entering any information.']
          : [
              'Do not enter credentials, passwords, or payment details on this website.',
              'Close the browser tab immediately.',
              'Access the official platform directly through verified bookmarks.',
            ],
      timestamp: DateTime.now(),
    );

    _scanHistory.insert(0, scan);
    return scan;
  }

  /// Verifies a digital receipt or screenshot, including direct PayPal API status checking
  Future<ShieldScanModel> analyzeReceipt({
    required String receiptName,
    required String claimedTransactionId,
    required double claimedAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final verifyRes = await PayPalSandboxService().verifyTransactionId(claimedTransactionId);
    final tx = verifyRes.dataOrNull;

    final indicators = <RiskIndicator>[];
    RiskTier tier = RiskTier.medium;
    double score = 0.30;

    bool exists = tx != null;

    if (!exists) {
      indicators.add(const RiskIndicator(
        code: 'IND_UNVERIFIED_TRANSACTION_ID',
        severity: 'CRITICAL',
        description: 'Claimed Transaction ID does not exist in PayPal provider records.',
      ));
      score = 0.92;
      tier = RiskTier.critical;
    } else {
      final amountDiff = (tx.sendAmount - claimedAmount).abs();
      if (amountDiff > 0.05) {
        indicators.add(RiskIndicator(
          code: 'IND_AMOUNT_MISMATCH',
          severity: 'HIGH',
          description: 'Provider record indicates ${tx.sendAmount} ${tx.sourceCurrency}, but receipt claims $claimedAmount.',
        ));
        score = 0.75;
        tier = RiskTier.high;
      } else {
        indicators.add(const RiskIndicator(
          code: 'IND_PROVIDER_VERIFIED',
          severity: 'LOW',
          description: 'Transaction ID matches authentic PayPal provider records exactly.',
        ));
        score = 0.10;
        tier = RiskTier.low;
      }
    }

    final scan = ShieldScanModel(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      scanType: ScanType.receipt,
      inputPayload: 'Receipt File: $receiptName | ID: $claimedTransactionId | Claimed: \$${claimedAmount.toStringAsFixed(2)}',
      riskTier: tier,
      confidenceScore: score,
      summary: exists
          ? 'Transaction ID confirmed in PayPal records. Note: Always verify settlement in your live balance before dispatching goods.'
          : 'High risk of fabricated receipt. The transaction reference provided does not exist on PayPal.',
      indicators: indicators,
      recommendedActions: [
        'A screenshot is never proof of payment arrival.',
        'Confirmation must always be verified via official payment provider records.',
        if (!exists) 'Do not release any work, deliverables, or merchandise to the buyer.',
      ],
      providerVerification: ProviderVerificationResult(
        checked: true,
        provider: 'PayPal Sandbox',
        transactionExists: exists,
        note: exists ? 'Verified against Sandbox ledger' : 'Transaction ID not found in Sandbox records',
      ),
      timestamp: DateTime.now(),
    );

    _scanHistory.insert(0, scan);
    return scan;
  }
}
