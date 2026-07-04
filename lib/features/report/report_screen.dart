import 'package:flutter/material.dart';
import 'package:my_order_pro/common/widgets/ananda_top_bar.dart';
import 'package:my_order_pro/data/services/analytics_service.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_summary == null) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await AnalyticsService().getSummary();
      setState(() {
        _summary = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load analytics: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AnandaTopBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDashboard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final data = _summary ?? {};
    final totalSales = (data['totalSales'] ?? 0.0) as num;
    final totalPurchases = (data['totalPurchases'] ?? 0.0) as num;
    final paymentsReceived = (data['paymentsIn'] ?? 0.0) as num;
    final paymentsPaid = (data['paymentsOut'] ?? 0.0) as num;
    final expenses = (data['totalExpenses'] ?? 0.0) as num;
    final outstanding = (data['totalOutstanding'] ?? 0.0) as num;
    final orders = (data['orderCount'] ?? 0) as num;

    return GridView.count(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      crossAxisCount: 2,
      crossAxisSpacing: Dimensions.paddingSizeSmall,
      mainAxisSpacing: Dimensions.paddingSizeSmall,
      childAspectRatio: 1.15,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _KpiCard(
          title: 'Total Sales',
          value: '₹ ${totalSales.toStringAsFixed(2)}',
          icon: Icons.trending_up,
          iconColor: AppColors.success,
        ),
        _KpiCard(
          title: 'Total Purchases',
          value: '₹ ${totalPurchases.toStringAsFixed(2)}',
          icon: Icons.shopping_cart_outlined,
          iconColor: AppColors.primary,
        ),
        _KpiCard(
          title: 'Payments Received',
          value: '₹ ${paymentsReceived.toStringAsFixed(2)}',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: AppColors.success,
        ),
        _KpiCard(
          title: 'Payments Paid',
          value: '₹ ${paymentsPaid.toStringAsFixed(2)}',
          icon: Icons.payment_outlined,
          iconColor: AppColors.error,
        ),
        _KpiCard(
          title: 'Expenses',
          value: '₹ ${expenses.toStringAsFixed(2)}',
          icon: Icons.receipt_long_outlined,
          iconColor: AppColors.error,
        ),
        _KpiCard(
          title: 'Outstanding',
          value: '₹ ${outstanding.toStringAsFixed(2)}',
          icon: Icons.warning_amber_outlined,
          iconColor: outstanding > 0 ? AppColors.error : AppColors.textMedium,
          valueColor: outstanding > 0 ? AppColors.error : AppColors.textDark,
        ),
        _KpiCard(
          title: 'Orders',
          value: '${orders.toInt()}',
          icon: Icons.list_alt_outlined,
          iconColor: AppColors.primaryDark,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: AppColors.textMedium,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: valueColor ?? AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}