import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/data/services/invoice_service.dart';
import 'package:my_order_pro/data/services/invoice_number_service.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/helper/pdf_invoice_helper.dart';

class SaleInvoiceScreen extends StatefulWidget {
  const SaleInvoiceScreen({super.key});

  @override
  State<SaleInvoiceScreen> createState() => _SaleInvoiceScreenState();
}

class _SaleInvoiceScreenState extends State<SaleInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _partyController = TextEditingController();
  final TextEditingController _companyGstinController = TextEditingController();
  final TextEditingController _partyGstinController = TextEditingController();
  DateTime _invoiceDate = DateTime.now();

  final List<_InvoiceLineItem> _lineItems = [];
  String _invoiceNo = 'INV-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _companyGstinController.addListener(_onItemChanged);
    _partyGstinController.addListener(_onItemChanged);
    _addLineItem();
    _initInvoiceNo();
  }

  Future<void> _initInvoiceNo() async {
    final no = await InvoiceNumberService().nextNumber(key: 'sale_invoice', prefix: 'INV');
    if (mounted) setState(() => _invoiceNo = no);
  }

  @override
  void dispose() {
    _partyController.dispose();
    _companyGstinController.dispose();
    _partyGstinController.dispose();
    for (final item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addLineItem() {
    setState(() {
      final newItem = _InvoiceLineItem();
      newItem.qtyController.addListener(_onItemChanged);
      newItem.rateController.addListener(_onItemChanged);
      _lineItems.add(newItem);
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      final item = _lineItems.removeAt(index);
      item.qtyController.removeListener(_onItemChanged);
      item.rateController.removeListener(_onItemChanged);
      item.dispose();
      if (_lineItems.isEmpty) {
        _addLineItem();
      }
    });
  }

  void _onItemChanged() {
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.surface,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _invoiceDate) {
      setState(() {
        _invoiceDate = picked;
      });
    }
  }

  Future<void> _saveInvoice() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_lineItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please add at least one item'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      for (final item in _lineItems) {
        if (item.qty <= 0 || item.rate <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Quantity and rate must be greater than 0 for all items'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      // Persist via InvoiceService (Supabase when configured, else in-memory).
      final ok = await InvoiceService().saveInvoice(
        partyName: _partyController.text,
        subtotal: _subtotal,
        gstAmount: _gstAmount,
        total: _grandTotal,
        items: _lineItems
            .map((it) => {
                  'item_name': it.nameController.text,
                  'qty': it.qty,
                  'rate': it.rate,
                  'amount': it.amount,
                })
            .toList(),
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Invoice saved' : 'Could not save invoice'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
        ),
      );
      if (!ok) return;

      // Reset form after save
      _formKey.currentState?.reset();
      _partyController.clear();
      _partyGstinController.clear();
      setState(() {
        _invoiceDate = DateTime.now();
        for (final item in _lineItems) {
          item.qtyController.removeListener(_onItemChanged);
          item.rateController.removeListener(_onItemChanged);
          item.dispose();
        }
        _lineItems.clear();
        _addLineItem();
      });
      _initInvoiceNo(); // fresh sequential number for the next invoice
    }
  }

  Future<void> _shareBill() async {
    if (_partyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Enter a party name first'), backgroundColor: AppColors.error),
      );
      return;
    }
    final items = _lineItems
        .where((it) => it.nameController.text.trim().isNotEmpty && it.amount > 0)
        .map((it) => {
              'name': it.nameController.text.trim(),
              'hsn': it.hsnController.text.trim(),
              'qty': it.qty,
              'rate': it.rate,
              'amount': it.amount,
              'gst_percent': it.gstPercent,
            })
        .toList();
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Add at least one item to share the bill'), backgroundColor: AppColors.error),
      );
      return;
    }
    final user = context.read<AuthProvider>().user;
    await PdfInvoiceHelper.shareInvoice(
      docTitle: 'TAX INVOICE',
      invoiceNo: _invoiceNo,
      date: _invoiceDate,
      partyName: _partyController.text.trim(),
      partyGstin: _partyGstinController.text.trim(),
      shopName: (user?.shopName.isNotEmpty ?? false) ? user!.shopName : 'MY ORDER PRO',
      shopAddress: user?.address ?? '',
      shopGstin: _companyGstinController.text.trim(),
      items: items,
      subtotal: _subtotal,
      cgst: _cgstAmount,
      sgst: _sgstAmount,
      igst: _igstAmount,
      total: _grandTotal,
    );
  }

  bool get _isInterState {
    final companyGstin = _companyGstinController.text.trim();
    final partyGstin = _partyGstinController.text.trim();
    if (companyGstin.length >= 2 && partyGstin.length >= 2) {
      return companyGstin.substring(0, 2) != partyGstin.substring(0, 2);
    }
    return false;
  }

  double get _subtotal {
    return _lineItems.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Per-item GST: each line taxed at its own rate (mixed baskets), then split by supply type.
  double get _totalTax {
    return _lineItems.fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  double get _cgstAmount => _isInterState ? 0.0 : _totalTax / 2;
  double get _sgstAmount => _isInterState ? 0.0 : _totalTax / 2;
  double get _igstAmount => _isInterState ? _totalTax : 0.0;

  double get _gstAmount => _totalTax;

  double get _grandTotal {
    return _subtotal + _gstAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sale Invoice'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Share / Print Bill',
            onPressed: _shareBill,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPartyField(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildGstinField(_companyGstinController, 'My GSTIN')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGstinField(_partyGstinController, 'Party GSTIN')),
                ],
              ),
              const SizedBox(height: 16),
              _buildDateRow(),
              const SizedBox(height: 24),
              Text(
                'Line Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _buildLineItemsList(),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _addLineItem,
                  icon: Icon(Icons.add, color: AppColors.primary),
                  label: Text(
                    'Add Item',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTotalsCard(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Invoice',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartyField() {
    return TextFormField(
      controller: _partyController,
      decoration: InputDecoration(
        labelText: 'Select Party',
        labelStyle: TextStyle(color: AppColors.textMedium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      style: TextStyle(color: AppColors.textDark),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a party name';
        }
        return null;
      },
    );
  }

  Widget _buildGstinField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textMedium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      style: TextStyle(color: AppColors.textDark),
      textCapitalization: TextCapitalization.characters,
      validator: (value) {
        if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
          return 'Min 2 chars';
        }
        return null;
      },
    );
  }

  Widget _buildDateRow() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Invoice Date',
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  '${_invoiceDate.day}/${_invoiceDate.month}/${_invoiceDate.year}',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _lineItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _lineItems[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: item.nameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        labelStyle: TextStyle(color: AppColors.textMedium, fontSize: 14),
                        isDense: true,
                        border: const UnderlineInputBorder(),
                      ),
                      style: TextStyle(color: AppColors.textDark),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => _removeLineItem(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: item.hsnController,
                      decoration: InputDecoration(
                        labelText: 'HSN/SAC',
                        labelStyle: TextStyle(color: AppColors.textMedium, fontSize: 14),
                        isDense: true,
                        border: const UnderlineInputBorder(),
                      ),
                      style: TextStyle(color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      initialValue: item.gstPercent,
                      isDense: true,
                      decoration: InputDecoration(
                        labelText: 'GST %',
                        labelStyle: TextStyle(color: AppColors.textMedium, fontSize: 14),
                        isDense: true,
                        border: const UnderlineInputBorder(),
                      ),
                      items: const [0, 5, 12, 18, 28]
                          .map((p) => DropdownMenuItem(value: p, child: Text('$p%')))
                          .toList(),
                      onChanged: (v) => setState(() => item.gstPercent = v ?? 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: item.qtyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Qty',
                        labelStyle: TextStyle(color: AppColors.textMedium, fontSize: 14),
                        isDense: true,
                        border: const UnderlineInputBorder(),
                      ),
                      style: TextStyle(color: AppColors.textDark),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Req';
                        if (double.tryParse(value) == null) return 'Inv';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: item.rateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Rate',
                        labelStyle: TextStyle(color: AppColors.textMedium, fontSize: 14),
                        isDense: true,
                        border: const UnderlineInputBorder(),
                      ),
                      style: TextStyle(color: AppColors.textDark),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Req';
                        if (double.tryParse(value) == null) return 'Inv';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.amount.toStringAsFixed(2),
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalsCard() {
    return Card(
      color: AppColors.card,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTotalRow('Subtotal', _subtotal, isBold: false),
            const SizedBox(height: 8),
            if (_isInterState)
              _buildTotalRow('IGST', _igstAmount, isBold: false)
            else ...[
              _buildTotalRow('CGST', _cgstAmount, isBold: false),
              const SizedBox(height: 8),
              _buildTotalRow('SGST', _sgstAmount, isBold: false),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(),
            ),
            _buildTotalRow('Grand Total', _grandTotal, isBold: true, color: AppColors.primaryDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {required bool isBold, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? (color ?? AppColors.textDark) : AppColors.textMedium,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isBold ? (color ?? AppColors.textDark) : AppColors.textDark,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _InvoiceLineItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController hsnController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  int gstPercent = 18;

  double get qty => double.tryParse(qtyController.text) ?? 0.0;
  double get rate => double.tryParse(rateController.text) ?? 0.0;
  double get amount => qty * rate;
  double get taxAmount => amount * gstPercent / 100.0;

  void dispose() {
    nameController.dispose();
    hsnController.dispose();
    qtyController.dispose();
    rateController.dispose();
  }
}