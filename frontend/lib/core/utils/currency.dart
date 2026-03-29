import 'dart:io';
import 'package:get/get.dart';
import '../services/storage_service.dart';

class RenewdCurrency {
  RenewdCurrency._();

  static const String inr = '\u20B9';
  static const String usd = '\$';
  static const String eur = '\u20AC';
  static const String gbp = '\u00A3';
  static const String aed = 'AED';

  static const Map<String, String> symbols = {
    'INR': inr,
    'USD': usd,
    'EUR': eur,
    'GBP': gbp,
    'AED': aed,
  };

  static const Map<String, String> labels = {
    'INR': 'Indian Rupee (\u20B9)',
    'USD': 'US Dollar (\$)',
    'EUR': 'Euro (\u20AC)',
    'GBP': 'British Pound (\u00A3)',
    'AED': 'UAE Dirham (AED)',
  };

  /// Get the user's default currency code
  static String get userCurrency {
    try {
      final storage = Get.find<StorageService>();
      final userData = storage.readUserData();
      return userData?['default_currency'] as String? ?? 'INR';
    } catch (_) {
      return 'INR';
    }
  }

  /// Get currency symbol for the user's default currency
  static String get symbol => symbols[userCurrency] ?? inr;

  /// Get symbol for a specific currency code
  static String symbolFor(String code) => symbols[code] ?? code;

  /// Format amount with user's default currency
  static String format(num amount) {
    final sym = symbol;
    if (amount == amount.toInt()) {
      return '$sym${_addCommas(amount.toInt().toString(), userCurrency)}';
    }
    return '$sym${amount.toStringAsFixed(2)}';
  }

  /// Detect currency from device locale
  static String detectFromLocale() {
    final locale = Platform.localeName; // e.g., "en_IN", "en_US"
    final country = locale.contains('_')
        ? locale.split('_').last.toUpperCase()
        : locale.toUpperCase();

    const countryToCurrency = {
      'IN': 'INR',
      'US': 'USD',
      'GB': 'GBP',
      'AE': 'AED',
      'DE': 'EUR',
      'FR': 'EUR',
      'IT': 'EUR',
      'ES': 'EUR',
      'NL': 'EUR',
      'AU': 'AUD',
      'CA': 'CAD',
      'SG': 'SGD',
      'JP': 'JPY',
    };

    return countryToCurrency[country] ?? 'INR';
  }

  /// Indian number system commas: 1,00,000
  static String _addCommas(String number, String currency) {
    if (number.length <= 3) return number;
    if (currency == 'INR') {
      final last3 = number.substring(number.length - 3);
      final rest = number.substring(0, number.length - 3);
      final withCommas = rest.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{2})+$)'),
        (m) => '${m[1]},',
      );
      return '$withCommas,$last3';
    }
    // Western comma system: 1,000,000
    return number.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]},',
    );
  }
}
