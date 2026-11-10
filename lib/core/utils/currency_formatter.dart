// Currency & Number Formatter
// Path: lib/core/utils/currency_formatter.dart

import 'package:intl/intl.dart';

abstract class CurrencyFormatter {
  static String format(double amount, String currencyCode, {bool hideSensitive = false}) {
    if (hideSensitive) {
      return '**** $currencyCode';
    }

    final symbol = switch (currencyCode.toUpperCase()) {
      'USD' => '\$',
      'EUR' => '€',
      'GBP' => '£',
      'KES' => 'KES ',
      'NGN' => '₦',
      'INR' => '₹',
      'PHP' => '₱',
      'CAD' => 'CA\$',
      _ => '$currencyCode ',
    };

    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$symbol${formatter.format(amount)}';
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);
  }
}
