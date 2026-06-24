/// App-wide constants, shared-preferences keys and config flags.
class AppConstants {
  AppConstants._();

  static const String appName = 'DAIRY DEMO';
  static const String appTagline = 'Aapka Wholesale Partner';
  static const String appVersion = '1.0.0';

  // Currency
  static const String currencySymbol = '₹'; // ₹

  // Base URL — wired for the future Laravel/REST backend. The app currently
  // runs off MockRepository so it is demoable without a server.
  static const String baseUrl = 'https://api.saathi.example';

  // SharedPreferences keys
  static const String token = 'saathi_token';
  static const String userPhone = 'saathi_user_phone';
  static const String userName = 'saathi_user_name';
  static const String shopName = 'saathi_shop_name';
  static const String cartList = 'saathi_cart_list';
  static const String themeMode = 'saathi_theme_mode';
  static const String onboardSeen = 'saathi_onboard_seen';

  // GST percentage applied at checkout (demo default).
  static const double gstPercent = 5.0;

  // Flat delivery charge; waived above the free-delivery threshold.
  static const double deliveryCharge = 49.0;
  static const double freeDeliveryThreshold = 5000.0;
}
