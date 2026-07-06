import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/repository.dart';
import 'package:my_order_pro/data/repository_provider.dart';
import 'package:my_order_pro/data/supabase_config.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/providers/cart_provider.dart';
import 'package:my_order_pro/providers/catalog_provider.dart';
import 'package:my_order_pro/providers/order_provider.dart';
import 'package:my_order_pro/providers/theme_provider.dart';
import 'package:my_order_pro/theme/app_theme.dart';
import 'package:my_order_pro/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Supabase only when real credentials are configured (see
  // lib/data/supabase_config.dart). Until then the app runs on MockRepository.
  if (SupabaseConfig.useSupabase) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // ignore: deprecated_member_use
      anonKey: SupabaseConfig.anonKey,
    );
  }

  final prefs = await SharedPreferences.getInstance();
  // RepositoryProvider auto-picks SupabaseRepository when configured, else Mock.
  final Repository repository = RepositoryProvider.instance;

  runApp(MyOrderProApp(prefs: prefs, repository: repository));
}

class MyOrderProApp extends StatefulWidget {
  final SharedPreferences prefs;
  final Repository repository;
  const MyOrderProApp({super.key, required this.prefs, required this.repository});

  @override
  State<MyOrderProApp> createState() => _MyOrderProAppState();
}

class _MyOrderProAppState extends State<MyOrderProApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    if (SupabaseConfig.useSupabase) {
      _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        if (event == AuthChangeEvent.signedOut) {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            RouteHelper.signIn,
            (route) => false,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs: widget.prefs)),
        ChangeNotifierProvider(create: (_) => AuthProvider(repository: widget.repository, prefs: widget.prefs)..loadUser()),
        ChangeNotifierProvider(create: (_) => CatalogProvider(repository: widget.repository)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider(repository: widget.repository, prefs: widget.prefs)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            initialRoute: RouteHelper.splash,
            onGenerateRoute: RouteHelper.onGenerateRoute,
          );
        },
      ),
    );
  }
}