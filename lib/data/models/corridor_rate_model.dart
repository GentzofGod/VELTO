// Corridor Rate & Provider Comparison Model
// Path: lib/data/models/corridor_rate_model.dart

class ProviderOption {
  final String providerName;
  final String providerId;
  final double fee;
  final double effectiveRate;
  final double recipientAmount;
  final String estimatedDelivery;
  final bool isDirectIntegration;
  final String note;

  const ProviderOption({
    required this.providerName,
    required this.providerId,
    required this.fee,
    required this.effectiveRate,
    required this.recipientAmount,
    required this.estimatedDelivery,
    this.isDirectIntegration = false,
    required this.note,
  });
}

class CorridorCalculation {
  final String sourceCurrency;
  final String targetCurrency;
  final double sendAmount;
  final double midMarketRate;
  final List<ProviderOption> providers;

  const CorridorCalculation({
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.sendAmount,
    required this.midMarketRate,
    required this.providers,
  });

  ProviderOption get recommendedProvider =>
      providers.firstWhere((p) => p.isDirectIntegration, orElse: () => providers.first);
}
