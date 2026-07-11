import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/data/supabase_config.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    auth.loadUser();
    final prefs = await SharedPreferences.getInstance();
    final onboardSeen = prefs.getBool(AppConstants.onboardSeen) ?? false;
    if (!mounted) return;

    Session? session;
    if (SupabaseConfig.useSupabase) {
      session = Supabase.instance.client.auth.currentSession;
    }

    if (auth.isLoggedIn && (!SupabaseConfig.useSupabase || session != null)) {
      await auth.refreshRole();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, RouteHelper.homeFor(auth.isDistributor));
    } else if (!onboardSeen) {
      Navigator.pushReplacementNamed(context, RouteHelper.onboarding);
    } else {
      Navigator.pushReplacementNamed(context, RouteHelper.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 26, height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
          ],
        ),
      ),
    );
  }
}