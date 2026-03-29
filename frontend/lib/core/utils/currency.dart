class RenewdCurrency {
  RenewdCurrency._();

  static const String inr = '\u20B9';
  static const String defaultSymbol = inr;

  /// Format amount with currency symbol: ₹5,000
  static String format(num amount, {String symbol = inr}) {
    if (amount == amount.toInt()) {
      return '$symbol${_addCommas(amount.toInt().toString())}';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Indian number system commas: 1,00,000
  static String _addCommas(String number) {
    if (number.length <= 3) return number;
    final last3 = number.substring(number.length - 3);
    final rest = number.substring(0, number.length - 3);
    final withCommas = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+$)'),
      (m) => '${m[1]},',
    );
    return '$withCommas,$last3';
  }
}
