import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/app_logo.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/features/settings/settings_screen.dart';
import 'package:my_order_pro/features/parties/parties_screen.dart';
import 'package:my_order_pro/features/item/items_screen.dart';
import 'package:my_order_pro/features/transactions/sale_invoice_screen.dart';
import 'package:my_order_pro/features/transactions/purchase_screen.dart';
import 'package:my_order_pro/features/expense/expense_screen.dart';
import 'package:my_order_pro/features/cash_bank/cash_bank_screen.dart';
import 'package:my_order_pro/features/backup/backup_restore_screen.dart';
import 'package:my_order_pro/features/online_store/online_store_screen.dart';
import 'package:my_order_pro/features/sync/sync_share_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.people_alt_rounded,
                  title: 'Parties',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PartiesScreen()));
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.inventory_2_rounded,
                  title: 'Items',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemsScreen()));
                  },
                ),
                const _DrawerDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.point_of_sale_rounded,
                  title: 'Sale',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SaleInvoiceScreen()));
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.shopping_cart_rounded,
                  title: 'Purchase',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseScreen()));
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.receipt_long_rounded,
                  title: 'Expense',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen()));
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.account_balance_rounded,
                  title: 'Cash & Bank',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CashBankScreen()));
                  },
                ),
                const _DrawerDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.storefront_rounded,
                  title: 'My Online Store',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineStoreScreen()));
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.sync_rounded,
                  title: 'Sync & Share',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncShareScreen()));
                  },
                ),
                const _DrawerDivider(),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.backup_rounded,
                  title: 'Backup & Restore',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupRestoreScreen()));
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    final shopName = (user != null && user.shopName.isNotEmpty) ? user.shopName : 'My Shop';
    final name = user?.name ?? '';
    final phone = user?.phone ?? '';
    final gstin = user?.gstin ?? '';

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 16,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                child: const AppLogo(size: 54),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopName,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: TextStyle(
                          color: AppColors.textDark.withValues(alpha: 0.75),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (name.isNotEmpty || gstin.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.textDark.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (name.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                              color: AppColors.textDark.withValues(alpha: 0.55),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  if (name.isNotEmpty && gstin.isNotEmpty)
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.textDark.withValues(alpha: 0.15),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  if (gstin.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GSTIN',
                            style: TextStyle(
                              color: AppColors.textDark.withValues(alpha: 0.55),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            gstin,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMedium),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}