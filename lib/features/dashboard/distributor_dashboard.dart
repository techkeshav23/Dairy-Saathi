import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_order_pro/common/widgets/app_drawer.dart';
import 'package:my_order_pro/features/more/more_screen.dart';
import 'package:my_order_pro/features/pos/mobile_pos_screen.dart';
import 'package:my_order_pro/features/report/report_screen.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/styles.dart';

/// The distributor (admin) shell — business dashboard + a drawer of accounting tools
/// (Parties, Sale, Purchase, Expense, Cash & Bank, Items, Online Store, Sync, Backup)
/// + quick POS. Shown only when the logged-in user's role is 'distributor'.
class DistributorDashboard extends StatefulWidget {
  const DistributorDashboard({super.key});

  @override
  State<DistributorDashboard> createState() => _DistributorDashboardState();
}

class _DistributorDashboardState extends State<DistributorDashboard> {
  int _index = 0;
  DateTime? _lastPressedAt;

  final _pages = const [ReportScreen(), MoreScreen()];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_index != 0) {
          setState(() => _index = 0);
          return;
        }
        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Press back again to exit'), duration: Duration(seconds: 2)),
          );
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        drawer: const AppDrawer(),
        body: IndexedStack(index: _index, children: _pages),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobilePosScreen())),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textDark,
          elevation: 3,
          icon: const Icon(Icons.point_of_sale),
          label: const Text('POS', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard', selected: _index == 0, onTap: () => setState(() => _index = 0)),
                  _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Account', selected: _index == 1, onTap: () => setState(() => _index = 1)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFF8A9094);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? activeIcon : icon, color: color, size: selected ? 26 : 24),
              const SizedBox(height: 4),
              Text(label, style: (selected ? robotoBold : robotoRegular).copyWith(color: color, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
