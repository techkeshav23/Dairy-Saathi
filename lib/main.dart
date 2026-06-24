import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saathi/data/repository.dart';
import 'package:saathi/helper/route_helper.dart';
import 'package:saathi/providers/auth_provider.dart';
import 'package:saathi/providers/cart_provider.dart';
import 'package:saathi/providers/catalog_provider.dart';
import 'package:saathi/providers/order_provider.dart';
import 'package:saathi/providers/theme_provider.dart';
import 'package:saathi/theme/dark_theme.dart';
import 'package:saathi/theme/light_theme.dart';
import 'package:saathi/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final Repository repository = MockRepository();

  runApp(SaathiApp(prefs: prefs, repository: repository));
}

class SaathiApp extends StatelessWidget {
  final SharedPreferences prefs;
  final Repository repository;
  const SaathiApp({super.key, required this.prefs, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs: prefs)),
        ChangeNotifierProvider(create: (_) => AuthProvider(repository: repository, prefs: prefs)..loadUser()),
        ChangeNotifierProvider(create: (_) => CatalogProvider(repository: repository)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider(repository: repository)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: RouteHelper.splash,
            onGenerateRoute: RouteHelper.onGenerateRoute,
          );
        },
      ),
    );
  }
}
