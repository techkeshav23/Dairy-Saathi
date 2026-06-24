import 'package:flutter/material.dart';
import 'package:saathi/features/home/home_screen.dart';
import 'package:saathi/features/more/more_screen.dart';
import 'package:saathi/features/report/report_screen.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/styles.dart';

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

  final _pages = const [
    HomeScreen(),
    ReportScreen(),
    MoreScreen(),
  ];

  void setTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded,
                    label: 'Home', selected: _index == 0, onTap: () => setTab(0)),
                _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded,
                    label: 'Report', selected: _index == 1, onTap: () => setTab(1)),
                _NavItem(icon: Icons.menu_rounded, activeIcon: Icons.menu_rounded,
                    label: 'More', selected: _index == 2, onTap: () => setTab(2)),
              ],
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
    required this.icon, required this.activeIcon,
    required this.label, required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFF8A9094);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: (selected ? robotoBold : robotoRegular)
                    .copyWith(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
