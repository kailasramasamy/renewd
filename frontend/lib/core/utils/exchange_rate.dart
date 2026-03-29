import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRate {
  ExchangeRate._();

  static Map<String, double>? _cachedRates;
  static DateTime? _cachedAt;

  /// Fetch all rates relative to USD, cached for 1 hour
  static Future<Map<String, double>> _fetchUsdRates() async {
    if (_cachedRates != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!).inHours < 1) {
      return _cachedRates!;
    }

    try {
      final response = await http.get(
        Uri.parse('https://latest.currency-api.pages.dev/v1/currencies/usd.json'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final usd = data['usd'] as Map<String, dynamic>;
        _cachedRates = usd.map((k, v) => MapEntry(k, (v as num).toDouble()));
        _cachedAt = DateTime.now();
        return _cachedRates!;
      }
    } catch (_) {}

    return _cachedRates ??
        {'inr': 85.0, 'eur': 0.92, 'gbp': 0.79, 'aed': 3.67};
  }

  /// Get rate: 1 USD = ? targetCurrency
  static Future<double> usdTo(String targetCurrency) async {
    final rates = await _fetchUsdRates();
    return rates[targetCurrency.toLowerCase()] ?? 1.0;
  }

  static double convert(double amount, double rate) {
    return (amount * rate * 100).roundToDouble() / 100;
  }
}
