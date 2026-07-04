import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_order_pro/common/widgets/app_drawer.dart';
import 'package:my_order_pro/features/home/home_screen.dart';
import 'package:my_order_pro/features/more/more_screen.dart';
import 'package:my_order_pro/features/pos/mobile_pos_screen.dart';
import 'package:my_order_pro/features/report/report_screen.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/styles.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();

  static void switchTab(BuildContext context, int index) =>
      context.findAncestorStateOfType<_DashboardScreenState>()?.setTab(index);
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _index = widget.initialIndex;
  DateTime? _lastPressedAt;

  final _pages = const [
    HomeScreen(),
    ReportScreen(),
    MoreScreen(),
  ];

  void setTab(int i) {
    if (_index == i) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_index != 0) {
          setTab(0);
          return;
        }
        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        drawer: const AppDrawer(),
        body: IndexedStack(index: _index, children: _pages),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MobilePosScreen()),
            );
          },
          backgroundColor: const Color(0xFFEA580C),
          elevation: 4,
          icon: const Icon(Icons.point_of_sale, color: Colors.white),
          label: const Text(
            'POS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    selected: _index == 0,
                    onTap: () => setTab(0),
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart_rounded,
                    label: 'Report',
                    selected: _index == 1,
                    onTap: () => setTab(1),
                  ),
                  _NavItem(
                    icon: Icons.menu_rounded,
                    activeIcon: Icons.menu_rounded,
                    label: 'More',
                    selected: _index == 2,
                    onTap: () => setTab(2),
                  ),
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

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFF8A9094);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(
                  selected ? activeIcon : icon,
                  key: ValueKey(selected),
                  color: color,
                  size: selected ? 26 : 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: (selected ? robotoBold : robotoRegular).copyWith(
                  color: color,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}