import 'package:flutter/material.dart';
import 'package:my_order_pro/data/models/category.dart';
import 'package:my_order_pro/data/models/order.dart';
import 'package:my_order_pro/data/models/product.dart';
import 'package:my_order_pro/features/auth/sign_in_screen.dart';
import 'package:my_order_pro/features/auth/sign_up_screen.dart';
import 'package:my_order_pro/features/cart/cart_screen.dart';
import 'package:my_order_pro/features/category/category_products_screen.dart';
import 'package:my_order_pro/features/category/place_order_screen.dart';
import 'package:my_order_pro/features/checkout/checkout_screen.dart';
import 'package:my_order_pro/features/checkout/order_success_screen.dart';
import 'package:my_order_pro/features/dashboard/dashboard_screen.dart';
import 'package:my_order_pro/features/dashboard/distributor_dashboard.dart';
import 'package:my_order_pro/features/item/product_detail_screen.dart';
import 'package:my_order_pro/features/ledger/ledger_screen.dart';
import 'package:my_order_pro/features/ledger/manual_recharge_screen.dart';
import 'package:my_order_pro/features/ledger/statement_screen.dart';
import 'package:my_order_pro/features/ledger/wallet_screen.dart';
import 'package:my_order_pro/features/onboard/onboarding_screen.dart';
import 'package:my_order_pro/features/order/all_orders_screen.dart';
import 'package:my_order_pro/features/order/order_detail_screen.dart';
import 'package:my_order_pro/features/profile/account_preferences_screen.dart';
import 'package:my_order_pro/features/profile/profile_screen.dart';
import 'package:my_order_pro/features/search/search_screen.dart';
import 'package:my_order_pro/features/splash/splash_screen.dart';

/// Central route registry.
class RouteHelper {
  RouteHelper._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String dashboard = '/dashboard';
  static const String distributorDashboard = '/distributor';
  static const String placeOrder = '/place-order';

  /// The home shell for a given role — distributor console vs retailer app.
  static String homeFor(bool isDistributor) => isDistributor ? distributorDashboard : dashboard;
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
  
  // Transaction & Drawer screens
  static const String sale = '/sale';
  static const String purchase = '/purchase';
  static const String expense = '/expense';
  static const String cashBank = '/cash-bank';
  static const String paymentIn = '/payment-in';
  static const String paymentOut = '/payment-out';

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
      case signUp:
        page = const SignUpScreen();
        break;
      case dashboard:
        page = const DashboardScreen();
        break;
      case distributorDashboard:
        page = const DistributorDashboard();
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
      case sale:
        page = const Scaffold(body: Center(child: Text('Sale')));
        break;
      case purchase:
        page = const Scaffold(body: Center(child: Text('Purchase')));
        break;
      case expense:
        page = const Scaffold(body: Center(child: Text('Expense')));
        break;
      case cashBank:
        page = const Scaffold(body: Center(child: Text('CashBank')));
        break;
      case paymentIn:
        page = const Scaffold(body: Center(child: Text('PaymentIn')));
        break;
      case paymentOut:
        page = const Scaffold(body: Center(child: Text('PaymentOut')));
        break;
      default:
        page = const Scaffold(body: Center(child: Text('Page not found')));
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}