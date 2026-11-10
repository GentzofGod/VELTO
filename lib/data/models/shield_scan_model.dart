// Veltro Shield Threat Model
// Path: lib/data/models/shield_scan_model.dart

enum RiskTier {
  low,
  medium,
  high,
  critical,
}

enum ScanType {
  message,
  link,
  receipt,
  invoice,
}

class RiskIndicator {
  final String code;
  final String severity;
  final String description;

  const RiskIndicator({
    required this.code,
    required this.severity,
    required this.description,
  });
}

class ProviderVerificationResult {
  final bool checked;
  final String provider;
  final bool transactionExists;
  final String? note;

  const ProviderVerificationResult({
    required this.checked,
    required this.provider,
    required this.transactionExists,
    this.note,
  });
}

class ShieldScanModel {
  final String id;
  final ScanType scanType;
  final String inputPayload;
  final RiskTier riskTier;
  final double confidenceScore;
  final String summary;
  final List<RiskIndicator> indicators;
  final List<String> recommendedActions;
  final ProviderVerificationResult? providerVerification;
  final DateTime timestamp;

  const ShieldScanModel({
    required this.id,
    required this.scanType,
    required this.inputPayload,
    required this.riskTier,
    required this.confidenceScore,
    required this.summary,
    required this.indicators,
    required this.recommendedActions,
    this.providerVerification,
    required this.timestamp,
  });

  String get riskLabel => switch (riskTier) {
    RiskTier.low => 'Low Risk',
    RiskTier.medium => 'Medium Risk',
    RiskTier.high => 'High Risk',
    RiskTier.critical => 'Critical Threat',
  };
}
