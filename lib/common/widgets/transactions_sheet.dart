import 'package:flutter/material.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/features/pos/mobile_pos_screen.dart';
import 'package:my_order_pro/features/transactions/sale_invoice_screen.dart';
import 'package:my_order_pro/features/transactions/purchase_screen.dart';
import 'package:my_order_pro/features/transactions/payment_in_screen.dart';
import 'package:my_order_pro/features/transactions/payment_out_screen.dart';
import 'package:my_order_pro/features/expense/expense_screen.dart';
import 'package:my_order_pro/features/transactions/document_form_screen.dart';
import 'package:my_order_pro/features/transactions/party_transfer_screen.dart';

void showTransactionsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _TransactionsSheet(),
  );
}

class _TransactionsSheet extends StatelessWidget {
  const _TransactionsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('SALE TRANSACTIONS'),
                    _buildGrid(context, _saleItems(context)),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('PURCHASE TRANSACTIONS'),
                    _buildGrid(context, _purchaseItems(context)),
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('OTHER TRANSACTIONS'),
                    _buildGrid(context, _otherItems(context)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildCloseButton(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textMedium,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<_TransactionItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 100,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.tintBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: AppColors.link, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                  height: 1.1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      customBorder: const CircleBorder(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.card,
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.close, color: AppColors.textDark, size: 28),
      ),
    );
  }

  List<_TransactionItem> _saleItems(BuildContext context) => [
        _TransactionItem('Sale\nInvoices', Icons.receipt_long_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SaleInvoiceScreen()),
          );
        }),
        _TransactionItem('Payment-In', Icons.account_balance_wallet_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaymentInScreen()),
          );
        }),
        _TransactionItem('Cr. Note /\nSale Return', Icons.assignment_return_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DocumentFormScreen(title: 'Credit Note', docTitle: 'CREDIT NOTE')),
          );
        }),
        _TransactionItem('Sale Order', Icons.shopping_cart_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DocumentFormScreen(title: 'Sale Order', docTitle: 'SALE ORDER')),
          );
        }),
        _TransactionItem('Estimate /\nQuotation', Icons.request_quote_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DocumentFormScreen(title: 'Estimate', docTitle: 'ESTIMATE')),
          );
        }),
        _TransactionItem('Delivery\nChallan', Icons.local_shipping_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DocumentFormScreen(title: 'Delivery Challan', docTitle: 'DELIVERY CHALLAN')),
          );
        }),
        _TransactionItem('Mobile POS', Icons.point_of_sale_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MobilePosScreen()),
          );
        }),
      ];

  List<_TransactionItem> _purchaseItems(BuildContext context) => [
        _TransactionItem('Purchase', Icons.shopping_bag_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PurchaseScreen()),
          );
        }),
        _TransactionItem('Payment-Out', Icons.payment_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaymentOutScreen()),
          );
        }),
        _TransactionItem('Dr. Note /\nPurchase Return', Icons.assignment_returned_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DocumentFormScreen(title: 'Debit Note', docTitle: 'DEBIT NOTE')),
          );
        }),
        _TransactionItem('Purchase\nOrder', Icons.add_shopping_cart_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DocumentFormScreen(title: 'Purchase Order', docTitle: 'PURCHASE ORDER')),
          );
        }),
      ];

  List<_TransactionItem> _otherItems(BuildContext context) => [
        _TransactionItem('Expenses', Icons.money_off_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpenseScreen()),
          );
        }),
        _TransactionItem('Party To Party\nTransfer', Icons.swap_horiz_outlined, () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PartyTransferScreen()),
          );
        }),
      ];
}

class _TransactionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  _TransactionItem(this.label, this.icon, this.onTap);
}