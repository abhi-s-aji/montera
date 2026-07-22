import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount,
      {String currency = 'USD', bool showSign = false}) {
    final symbol = _getCurrencySymbol(currency);
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );

    final absFormatted = formatter.format(amount.abs());

    if (amount < 0) {
      return '-$absFormatted';
    } else if (amount > 0 && showSign) {
      return '+$absFormatted';
    }
    return absFormatted;
  }

  static String _getCurrencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'A\$';
      default:
        return '$code ';
    }
  }
}
