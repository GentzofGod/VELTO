// API & Corridor Constants
// Path: lib/core/constants/api_constants.dart

class CurrencyOption {
  final String code;
  final String name;
  final String country;
  final String symbol;

  const CurrencyOption({
    required this.code,
    required this.name,
    required this.country,
    required this.symbol,
  });
}

abstract class ApiConstants {
  static const String appName = 'Veltro';
  static const String appTagline = 'Move money smarter. Stay one step ahead.';

  // Supported Currency List
  static const List<CurrencyOption> supportedCurrencies = [
    CurrencyOption(code: 'USD', name: 'United States Dollar', country: 'United States', symbol: '\$'),
    CurrencyOption(code: 'EUR', name: 'Euro', country: 'European Union', symbol: '€'),
    CurrencyOption(code: 'GBP', name: 'British Pound Sterling', country: 'United Kingdom', symbol: '£'),
    CurrencyOption(code: 'KES', name: 'Kenyan Shilling', country: 'Kenya', symbol: 'KES'),
    CurrencyOption(code: 'NGN', name: 'Nigerian Naira', country: 'Nigeria', symbol: '₦'),
    CurrencyOption(code: 'INR', name: 'Indian Rupee', country: 'India', symbol: '₹'),
    CurrencyOption(code: 'PHP', name: 'Philippine Peso', country: 'Philippines', symbol: '₱'),
    CurrencyOption(code: 'CAD', name: 'Canadian Dollar', country: 'Canada', symbol: 'CA\$'),
  ];

  // Base Exchange Rates to USD (mid-market index)
  static const Map<String, double> usdExchangeRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'KES': 129.50,
    'NGN': 1620.00,
    'INR': 83.40,
    'PHP': 58.20,
    'CAD': 1.37,
  };

  // Backend Endpoints
  static const String defaultSupabaseUrl = 'https://demo-veltro.supabase.co';
  static const String defaultPayPalSandboxUrl = 'https://api-m.sandbox.paypal.com';
}
