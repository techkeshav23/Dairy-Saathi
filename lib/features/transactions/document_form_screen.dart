import 'package:flutter/material.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/helper/pdf_invoice_helper.dart';
import 'package:my_order_pro/data/services/document_service.dart';
import 'package:my_order_pro/data/services/invoice_number_service.dart';

class DocumentFormScreen extends StatefulWidget {
  final String title;
  final String docTitle;

  const DocumentFormScreen({
    super.key,
    required this.title,
    required this.docTitle,
  });

  @override
  State<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends State<DocumentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _partyController = TextEditingController();
  final TextEditingController _partyGstinController = TextEditingController();
  DateTime _documentDate = DateTime.now();

  final List<_DocumentLineItem> _lineItems = [];
  late String _docNo;

  @override
  void initState() {
    super.initState();
    final prefix = widget.docTitle.length >= 3
        ? widget.docTitle.substring(0, 3).toUpperCase()
        : 'DOC';
    _docNo = '$prefix-${DateTime.now().millisecondsSinceEpoch}';
    _initDocNo(prefix);
    _partyGstinController.addListener(_onItemChanged);
    _addLineItem();
  }

  Future<void> _initDocNo(String prefix) async {
    try {
      final nextNo = await InvoiceNumberService().nextNumber(
        key: widget.docTitle,
        prefix: prefix,
      );
      if (mounted) {
        setState(() {
          _docNo = nextNo;
        });
      }
    } catch (_) {
      // fallback keeps current behavior
    }
  }

  @override
  void dispose() {
    _partyController.dispose();
    _partyGstinController.dispose();
    for (final item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addLineItem() {
    setState(() {
      final newItem = _DocumentLineItem();
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
      initialDate: _documentDate,
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
    if (picked != null && picked != _documentDate) {
      setState(() {
        _documentDate = picked;
      });
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  /// Validates the form and returns the line items as maps, or null if invalid.
  List<Map<String, dynamic>>? _collectItems() {
    if (!(_formKey.currentState?.validate() ?? false)) return null;
    if (_partyController.text.trim().isEmpty) {
      _snack('Enter a party name first', AppColors.error);
      return null;
    }
    final items = _lineItems
        .where((it) =>
            it.nameController.text.trim().isNotEmpty && it.qty > 0 && it.rate > 0)
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
      _snack('Add at least one valid item (qty > 0, rate > 0)', AppColors.error);
      return null;
    }
    return items;
  }

  Future<void> _shareDocument() async {
    final items = _collectItems();
    if (items == null) return;
    await PdfInvoiceHelper.shareInvoice(
      docTitle: widget.docTitle,
      invoiceNo: _docNo,
      date: _documentDate,
      partyName: _partyController.text.trim(),
      partyGstin: _partyGstinController.text.trim(),
      items: items,
      subtotal: _subtotal,
      cgst: _cgstAmount,
      sgst: _sgstAmount,
      total: _grandTotal,
    );
  }

  Future<void> _saveDocument() async {
    final items = _collectItems();
    if (items == null) return;
    try {
      final ok = await DocumentService().saveDocument(
        docType: widget.docTitle,
        docNo: _docNo,
        partyName: _partyController.text.trim(),
        partyGstin: _partyGstinController.text.trim(),
        date: _documentDate,
        subtotal: _subtotal,
        cgst: _cgstAmount,
        sgst: _sgstAmount,
        total: _grandTotal,
        items: items,
      );
      if (!mounted) return;
      _snack(ok ? '${widget.title} saved' : 'Could not save ${widget.title}',
          ok ? AppColors.success : AppColors.error);
    } catch (e) {
      if (!mounted) return;
      _snack('Save failed — check your connection', AppColors.error);
    }
  }

  double get _subtotal {
    return _lineItems.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalTax {
    return _lineItems.fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  double get _cgstAmount => _totalTax / 2;
  double get _sgstAmount => _totalTax / 2;
  double get _grandTotal => _subtotal + _totalTax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDocument,
            tooltip: 'Share ${widget.title}',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _partyController,
              decoration: const InputDecoration(
                labelText: 'Party Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _partyGstinController,
              decoration: const InputDecoration(
                labelText: 'Party GSTIN (Optional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Document Date'),
              subtitle: Text(
                  '${_documentDate.day.toString().padLeft(2, '0')}/${_documentDate.month.toString().padLeft(2, '0')}/${_documentDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              tileColor: Colors.transparent,
            ),
            const SizedBox(height: 24),
            const Text(
              'Line Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._lineItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: item.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Item Name',
                                isDense: true,
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: item.hsnController,
                              decoration: const InputDecoration(
                                labelText: 'HSN/SAC',
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: AppColors.error,
                            onPressed: () => _removeLineItem(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: item.qtyController,
                              decoration: const InputDecoration(
                                labelText: 'Qty',
                                isDense: true,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: item.rateController,
                              decoration: const InputDecoration(
                                labelText: 'Rate (₹)',
                                isDense: true,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<int>(
                              initialValue: item.gstPercent,
                              decoration: const InputDecoration(
                                labelText: 'GST %',
                                isDense: true,
                              ),
                              isExpanded: true,
                              items: [0, 5, 12, 18, 28]
                                  .map((p) => DropdownMenuItem(
                                        value: p,
                                        child: Text('$p%'),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    item.gstPercent = val;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '₹${item.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addLineItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Totals',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildTotalRow('Subtotal', _subtotal),
                    _buildTotalRow('CGST', _cgstAmount),
                    _buildTotalRow('SGST', _sgstAmount),
                    const Divider(),
                    _buildTotalRow('Grand Total', _grandTotal, isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveDocument,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareDocument,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentLineItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController hsnController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController rateController = TextEditingController(text: '0');
  int gstPercent = 18;

  double get qty => double.tryParse(qtyController.text) ?? 0.0;
  double get rate => double.tryParse(rateController.text) ?? 0.0;
  double get amount => qty * rate;
  double get taxAmount => amount * gstPercent / 100;

  void dispose() {
    nameController.dispose();
    hsnController.dispose();
    qtyController.dispose();
    rateController.dispose();
  }
}