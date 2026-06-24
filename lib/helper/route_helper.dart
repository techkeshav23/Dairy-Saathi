import 'package:flutter/material.dart';
import 'package:saathi/data/models/category.dart';
import 'package:saathi/data/models/order.dart';
import 'package:saathi/data/models/product.dart';
import 'package:saathi/features/auth/sign_in_screen.dart';
import 'package:saathi/features/auth/verify_otp_screen.dart';
import 'package:saathi/features/cart/cart_screen.dart';
import 'package:saathi/features/category/category_products_screen.dart';
import 'package:saathi/features/category/place_order_screen.dart';
import 'package:saathi/features/checkout/checkout_screen.dart';
import 'package:saathi/features/checkout/order_success_screen.dart';
import 'package:saathi/features/dashboard/dashboard_screen.dart';
import 'package:saathi/features/item/product_detail_screen.dart';
import 'package:saathi/features/ledger/ledger_screen.dart';
import 'package:saathi/features/ledger/manual_recharge_screen.dart';
import 'package:saathi/features/ledger/statement_screen.dart';
import 'package:saathi/features/ledger/wallet_screen.dart';
import 'package:saathi/features/onboard/onboarding_screen.dart';
import 'package:saathi/features/order/all_orders_screen.dart';
import 'package:saathi/features/order/order_detail_screen.dart';
import 'package:saathi/features/profile/account_preferences_screen.dart';
import 'package:saathi/features/profile/profile_screen.dart';
import 'package:saathi/features/search/search_screen.dart';
import 'package:saathi/features/splash/splash_screen.dart';

/// Central route registry.
class RouteHelper {
  RouteHelper._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String verifyOtp = '/verify-otp';
  static const String dashboard = '/dashboard';
  static const String placeOrder = '/place-order';
  static const String categoryProducts = '/category';
  static const String productDetail = '/product';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String allOrders = '/all-orders';
  static const String orderDetail = '/order-detail';
  static const String statement = '/statement';
  static const String wallet = '/wallet';
  static const String manualRecharge = '/manual-recharge';
  static const String ledger = '/ledger';
  static const String accountPreferences = '/account-preferences';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case splash:
        page = const SplashScreen();
        break;
      case onboarding:
        page = const OnboardingScreen();
        break;
      case signIn:
        page = const SignInScreen();
        break;
      case verifyOtp:
        page = VerifyOtpScreen(phone: settings.arguments as String);
        break;
      case dashboard:
        page = const DashboardScreen();
        break;
      case placeOrder:
        page = const PlaceOrderScreen();
        break;
      case categoryProducts:
        page = CategoryProductsScreen(category: settings.arguments as CategoryModel);
        break;
      case productDetail:
        page = ProductDetailScreen(product: settings.arguments as Product);
        break;
      case search:
        page = const SearchScreen();
        break;
      case cart:
        page = const CartScreen();
        break;
      case checkout:
        page = const CheckoutScreen();
        break;
      case orderSuccess:
        page = OrderSuccessScreen(order: settings.arguments as OrderModel);
        break;
      case allOrders:
        page = const AllOrdersScreen();
        break;
      case orderDetail:
        page = OrderDetailScreen(order: settings.arguments as OrderModel);
        break;
      case statement:
        page = const StatementScreen();
        break;
      case wallet:
        page = const WalletScreen();
        break;
      case manualRecharge:
        page = const ManualRechargeScreen();
        break;
      case ledger:
        page = const LedgerScreen();
        break;
      case accountPreferences:
        page = const AccountPreferencesScreen();
        break;
      case profile:
        page = const ProfileScreen();
        break;
      default:
        page = const Scaffold(body: Center(child: Text('Page not found')));
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
