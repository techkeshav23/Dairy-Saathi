import 'package:flutter/material.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';
import 'package:my_order_pro/data/services/payment_service.dart';

class CashBankScreen extends StatefulWidget {
  const CashBankScreen({super.key});

  @override
  State<CashBankScreen> createState() => _CashBankScreenState();
}

class _CashBankScreenState extends State<CashBankScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _payments = [];
  double _cashBalance = 0.0;
  double _bankBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final payments = await PaymentService().listPayments();
      
      double cashIn = 0.0;
      double cashOut = 0.0;
      double bankIn = 0.0;
      double bankOut = 0.0;

      for (dynamic payment in payments) {
        if (payment is Map) {
          final double amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0.0;
          final String mode = payment['mode']?.toString() ?? '';
          final String direction = payment['direction']?.toString() ?? '';

          if (mode.toLowerCase() == 'cash') {
            if (direction == 'in') {
              cashIn += amount;
            } else if (direction == 'out') {
              cashOut += amount;
            }
          } else if (['bank', 'upi', 'cheque', 'card'].contains(mode.toLowerCase())) {
            if (direction == 'in') {
              bankIn += amount;
            } else if (direction == 'out') {
              bankOut += amount;
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _payments = payments;
          _cashBalance = cashIn - cashOut;
          _bankBalance = bankIn - bankOut;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: Text(
          'Cash & Bank',
          style: robotoBold.copyWith(color: AppColors.textDark, fontSize: Dimensions.fontSizeLarge),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPayments,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPayments,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _payments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_error != null && _payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text('Failed to load data', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(_error!, style: robotoRegular.copyWith(color: AppColors.textMedium)),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            ElevatedButton(
              onPressed: _fetchPayments,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildSummarySection(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault, 
              Dimensions.paddingSizeSmall, 
              Dimensions.paddingSizeDefault, 
              Dimensions.paddingSizeSmall
            ),
            child: Text(
              'Recent Transactions',
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: AppColors.textDark),
            ),
          ),
        ),
        if (_payments.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textLight.withValues(alpha: 0.5)),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Text(
                    'No transactions yet',
                    style: robotoMedium.copyWith(color: AppColors.textMedium, fontSize: Dimensions.fontSizeLarge),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPaymentItem(_payments[index]),
                childCount: _payments.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: Dimensions.paddingSizeExtraLarge)),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              title: 'Cash in Hand',
              balance: _cashBalance,
              icon: Icons.payments_outlined,
              color: const Color(0xFF4CAF50), // Green
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: _buildSummaryCard(
              title: 'Bank / Digital',
              balance: _bankBalance,
              icon: Icons.account_balance_outlined,
              color: const Color(0xFF2196F3), // Blue
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double balance,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            title,
            style: robotoMedium.copyWith(
              color: AppColors.textMedium,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${balance.toStringAsFixed(2)}',
            style: robotoBold.copyWith(
              color: AppColors.textDark,
              fontSize: Dimensions.fontSizeExtraLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(dynamic payment) {
    String party = 'Unknown Party';
    String mode = 'Unknown Mode';
    String direction = 'in';
    double amount = 0.0;
    String? dateStr;

    if (payment is Map) {
      party = payment['party_name']?.toString() ?? payment['partyName']?.toString() ?? 'Unknown Party';
      mode = payment['mode']?.toString() ?? 'Unknown Mode';
      direction = payment['direction']?.toString() ?? 'in';
      amount = double.tryParse(payment['amount']?.toString() ?? '0') ?? 0.0;
      dateStr = payment['created_at']?.toString() ?? payment['date']?.toString();
    }

    final bool isOut = direction == 'out';
    final Color amountColor = isOut ? AppColors.error : AppColors.success;
    final String sign = isOut ? '-' : '+';
    final IconData directionIcon = isOut ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    // Format date if available
    String formattedDate = '';
    if (dateStr != null) {
      try {
        final date = DateTime.parse(dateStr);
        formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (_) {
        formattedDate = dateStr.split('T').first;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.02),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault, 
          vertical: Dimensions.paddingSizeExtraSmall
        ),
        leading: CircleAvatar(
          backgroundColor: amountColor.withValues(alpha: 0.1),
          child: Icon(directionIcon, color: amountColor, size: 20),
        ),
        title: Text(
          party,
          style: robotoSemiBold.copyWith(
            color: AppColors.textDark,
            fontSize: Dimensions.fontSizeDefault,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  mode,
                  style: robotoMedium.copyWith(
                    color: AppColors.textMedium,
                    fontSize: Dimensions.fontSizeExtraSmall,
                  ),
                ),
              ),
              if (formattedDate.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: robotoRegular.copyWith(
                    color: AppColors.textLight,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Text(
          '$sign ₹${amount.toStringAsFixed(2)}',
          style: robotoBold.copyWith(
            color: amountColor,
            fontSize: Dimensions.fontSizeLarge,
          ),
        ),
      ),
    );
  }
}