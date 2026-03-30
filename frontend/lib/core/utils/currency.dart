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
      return userData?['default_currency'] as String? ?? 'USD';
    } catch (_) {
      return 'USD';
    }
  }

  /// Get currency symbol for the user's default currency
  static String get symbol => symbols[userCurrency] ?? usd;

  /// Get symbol for a specific currency code
  static String symbolFor(String code) => symbols[code] ?? code;

  /// Format amount with user's default currency and locale-aware commas
  static String format(num amount, {int decimals = 0}) {
    final sym = symbol;
    final currency = userCurrency;
    if (decimals > 0) {
      final parts = amount.toStringAsFixed(decimals).split('.');
      return '$sym${_addCommas(parts[0], currency)}.${parts[1]}';
    }
    return '$sym${_addCommas(amount.toInt().toString(), currency)}';
  }

  /// Compact format for stats cards: ₹2.5L (INR) or $250K (others)
  static String formatCompact(num amount) {
    final sym = symbol;
    final currency = userCurrency;
    if (currency == 'INR') {
      if (amount >= 10000000) {
        final cr = amount / 10000000;
        return '$sym${_compactNum(cr)}Cr';
      }
      if (amount >= 100000) {
        final lakhs = amount / 100000;
        return '$sym${_compactNum(lakhs)}L';
      }
      return '$sym${_addCommas(amount.toInt().toString(), currency)}';
    }
    // Western: K, M
    if (amount >= 1000000) {
      final millions = amount / 1000000;
      return '$sym${_compactNum(millions)}M';
    }
    if (amount >= 100000) {
      final thousands = amount / 1000;
      return '$sym${thousands.toInt()}K';
    }
    return '$sym${_addCommas(amount.toInt().toString(), currency)}';
  }

  static String _compactNum(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  /// Get the country code from device locale (e.g., "IN", "US")
  static String get deviceCountry {
    final locale = Platform.localeName; // e.g., "en_IN", "en_US"
    return locale.contains('_')
        ? locale.split('_').last.toUpperCase()
        : locale.toUpperCase();
  }

  /// Country code to phone dial code mapping
  static const Map<String, String> _countryToDialCode = {
    'IN': '+91',
    'US': '+1',
    'GB': '+44',
    'AE': '+971',
    'DE': '+49',
    'FR': '+33',
    'IT': '+39',
    'ES': '+34',
    'NL': '+31',
    'AU': '+61',
    'CA': '+1',
    'SG': '+65',
    'JP': '+81',
    'BR': '+55',
    'MX': '+52',
    'ZA': '+27',
    'KR': '+82',
    'CN': '+86',
    'RU': '+7',
    'SA': '+966',
    'NZ': '+64',
    'PH': '+63',
    'MY': '+60',
    'TH': '+66',
    'ID': '+62',
    'NG': '+234',
    'KE': '+254',
    'EG': '+20',
    'PK': '+92',
    'BD': '+880',
  };

  /// Detect phone dial code from device locale
  static String detectDialCode() =>
      _countryToDialCode[deviceCountry] ?? '+1';

  /// Detect currency from device locale
  static String detectFromLocale() {
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

    return countryToCurrency[deviceCountry] ?? 'USD';
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
