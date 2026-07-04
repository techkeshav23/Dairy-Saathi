import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/ananda_top_bar.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/app_constants.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';
import '../../common/widgets/powered_by_codeblimp.dart';
import 'package:my_order_pro/features/settings/settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AnandaTopBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              children: [
                Text('Statement & Wallet', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Row(
                  children: [
                    _tile(context, Icons.description_outlined, 'Statement', RouteHelper.statement),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    _tile(context, Icons.account_balance_wallet_outlined, 'Wallet', RouteHelper.wallet),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    _tile(context, Icons.savings_outlined, 'Manual\nRecharge', RouteHelper.manualRecharge),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                _sectionHeader('Profile'),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _card([
                  _row(context, Icons.settings_outlined, 'Settings',
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))),
                  _row(context, Icons.manage_accounts_outlined, 'Account and Preferences',
                      () => Navigator.pushNamed(context, RouteHelper.accountPreferences)),
                  _row(context, Icons.help_outline, 'Help', () => _toast(context, 'Help — demo')),
                  _row(context, Icons.info_outline, 'About App Developer', () => _about(context)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                _sectionHeader('Account Setting'),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                _card([
                  _row(context, null, 'Logout', () => _logout(context),
                      trailing: const Icon(Icons.logout, color: AppColors.primary, size: 22)),
                ]),
                const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

                _poweredBy(),
                const SizedBox(height: Dimensions.paddingSizeLarge),
              ],
            ),
          ),
        
          const SizedBox(height: 24),
          const PoweredByCodeBlimp(),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF2D2D2D)),
              const SizedBox(height: 8),
              Container(width: 26, height: 3, decoration: BoxDecoration(
                  color: const Color(0xFFCFD6DA), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, height: 1.1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String t) => Text(t, style: robotoBold.copyWith(
      color: AppColors.primary, fontSize: Dimensions.fontSizeLarge));

  Widget _card(List<Widget> rows) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i < rows.length - 1) const Divider(height: 1, color: Color(0xFFE6E9EB)),
            ],
          ],
        ),
      );

  Widget _row(BuildContext context, IconData? icon, String label, VoidCallback onTap, {Widget? trailing}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFF2D2D2D), size: 22),
              const SizedBox(width: Dimensions.paddingSizeDefault),
            ],
            Expanded(child: Text(label, style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault, color: const Color(0xFF333A3D)))),
            trailing ?? const Icon(Icons.chevron_right, color: Color(0xFF9AA0A4), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _poweredBy() {
    Widget circle(String l, Color c) => Container(
          width: 26, height: 26, alignment: Alignment.center,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          child: Text(l, style: robotoBold.copyWith(color: Colors.white, fontSize: 12)),
        );
    return Column(
      children: [
        Text('Powered By', style: robotoSemiBold.copyWith(
            color: const Color(0xFF2D3436), fontSize: Dimensions.fontSizeSmall)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            circle('D', const Color(0xFF1597A5)),
            Transform.translate(offset: const Offset(-4, 0), child: circle('I', const Color(0xFFB11E2F))),
            Transform.translate(offset: const Offset(-8, 0), child: circle('A', const Color(0xFF3DA546))),
            Transform.translate(offset: const Offset(-12, 0), child: circle('L', const Color(0xFFF2A823))),
            Transform.translate(offset: const Offset(-8, 0),
                child: Text('ERP', style: robotoBold.copyWith(color: const Color(0xFF1A1A1A), fontSize: 16))),
          ],
        ),
      ],
    );
  }

  void _toast(BuildContext context, String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  void _about(BuildContext context) => showAboutDialog(
        context: context,
        applicationName: AppConstants.appName,
        applicationVersion: 'v${AppConstants.appVersion}',
        applicationLegalese: '${AppConstants.appTagline}\nWholesale ordering demo.',
      );

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log out?', style: robotoBold),
        content: const Text('You will need to log in again to place orders.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: Text('Log out', style: robotoMedium.copyWith(color: AppColors.error))),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, RouteHelper.signIn, (r) => false);
  }
}