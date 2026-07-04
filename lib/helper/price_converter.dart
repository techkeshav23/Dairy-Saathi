import 'package:intl/intl.dart';
import 'package:my_order_pro/util/app_constants.dart';

/// Formats money in Indian numbering (lakhs/crores) with the ₹ symbol.
class PriceConverter {
  PriceConverter._();

  static final NumberFormat _inr =
      NumberFormat.decimalPattern('en_IN');

  static String format(num amount) {
    final rounded = amount.round();
    return '${AppConstants.currencySymbol}${_inr.format(rounded)}';
  }

  /// Same as [format] but keeps two decimals (for unit prices).
  static String formatPrecise(num amount) {
    final f = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    );
    return f.format(amount);
  }
}
