import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/common/widgets/powered_by_codeblimp.dart';
import 'package:my_order_pro/features/parties/parties_screen.dart';
import 'package:my_order_pro/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDistributor = context.watch<AuthProvider>().isDistributor;

    if (!isDistributor) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.card,
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          iconTheme: const IconThemeData(color: AppColors.textDark),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Business settings are available only for distributor accounts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGroup([
                  _buildTile(Icons.settings_outlined, 'General', isNew: true),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildTile(Icons.receipt_long_outlined, 'Transaction', isNew: true),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildTile(Icons.print_outlined, 'Invoice Print'),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildTile(Icons.account_balance_outlined, 'Taxes & GST'),
                ]),
                const SizedBox(height: 16),
                
                _buildGroup([
                  _buildTile(Icons.group_outlined, 'User Management'),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildTile(Icons.sms_outlined, 'Transaction SMS'),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildTile(Icons.notifications_active_outlined, 'Reminders'),
                ]),
                const SizedBox(height: 16),
                
                _buildGroup([
                  _buildTile(
                    Icons.business_outlined, 
                    'Party',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PartiesScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildTile(Icons.inventory_2_outlined, 'Item'),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildTile(Icons.currency_exchange_outlined, 'Multi-Currency'),
                ]),
              ]),
            ),
          ),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 40.0, bottom: 48.0),
                child: PoweredByCodeBlimp(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(List<Widget> children) {
    return Material(
      color: AppColors.card,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, {bool isNew = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      leading: Icon(icon, color: AppColors.textMedium),
      title: Semantics(
        label: isNew ? '$title, New' : title,
        excludeSemantics: true,
        child: Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isNew) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
      onTap: onTap ?? () {
        // TODO: Navigate to respective settings screen
      },
    );
  }
}
