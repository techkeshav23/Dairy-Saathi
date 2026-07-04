import 'package:flutter/material.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/data/services/purchase_service.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseLineItem {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  double get amount {
    final qty = double.tryParse(qtyController.text) ?? 0.0;
    final rate = double.tryParse(rateController.text) ?? 0.0;
    return qty * rate;
  }

  void dispose() {
    itemController.dispose();
    qtyController.dispose();
    rateController.dispose();
  }
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierController = TextEditingController();
  final _billNoController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<_PurchaseLineItem> _lineItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addLineItem();
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _billNoController.dispose();
    for (final item in _lineItems) {
      item.qtyController.removeListener(_onLineItemChanged);
      item.rateController.removeListener(_onLineItemChanged);
      item.dispose();
    }
    super.dispose();
  }

  void _addLineItem() {
    final newItem = _PurchaseLineItem();
    newItem.qtyController.addListener(_onLineItemChanged);
    newItem.rateController.addListener(_onLineItemChanged);
    setState(() {
      _lineItems.add(newItem);
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      final item = _lineItems.removeAt(index);
      item.qtyController.removeListener(_onLineItemChanged);
      item.rateController.removeListener(_onLineItemChanged);
      item.dispose();
    });
  }

  void _onLineItemChanged() {
    setState(() {});
  }

  double _calculateTotal() {
    return _lineItems.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.surface,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _savePurchase() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_lineItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one line item.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      for (final item in _lineItems) {
        final qty = double.tryParse(item.qtyController.text) ?? 0.0;
        final rate = double.tryParse(item.rateController.text) ?? 0.0;
        if (qty <= 0 || rate <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All line items must have quantity and rate greater than 0.'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final subtotal = _calculateTotal();
        final gstAmount = subtotal * 0.18;
        final ok = await PurchaseService().savePurchase(
          supplierName: _supplierController.text,
          billNo: _billNoController.text,
          subtotal: subtotal,
          gstAmount: gstAmount,
          total: subtotal + gstAmount,
          items: _lineItems
              .map((it) => {
                    'item_name': it.itemController.text,
                    'quantity': double.tryParse(it.qtyController.text) ?? 0.0,
                    'rate': double.tryParse(it.rateController.text) ?? 0.0,
                    'total': it.amount,
                  })
              .toList(),
        );
        
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Purchase saved successfully!' : 'Could not save purchase'),
            backgroundColor: ok ? AppColors.success : AppColors.error,
          ),
        );
        
        if (ok) {
          _formKey.currentState?.reset();
          _supplierController.clear();
          _billNoController.clear();
          setState(() {
            _selectedDate = DateTime.now();
            for (final item in _lineItems) {
              item.qtyController.removeListener(_onLineItemChanged);
              item.rateController.removeListener(_onLineItemChanged);
              item.dispose();
            }
            _lineItems.clear();
            _addLineItem();
          });
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textMedium),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.textLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.textLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateTotal();
    final gst = subtotal * 0.18;
    final total = subtotal + gst;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Purchase',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.textLight.withValues(alpha: 0.2),
            height: 1.0,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _supplierController,
                decoration: _inputDecoration('Supplier Name'),
                style: const TextStyle(color: AppColors.textDark),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter supplier name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _billNoController,
                decoration: _inputDecoration('Bill Number'),
                style: const TextStyle(color: AppColors.textDark),
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter bill number' : null,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.textLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: AppColors.textDark, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text('Change', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Items',
                style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lineItems.length,
                itemBuilder: (context, index) {
                  final item = _lineItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: AppColors.surface,
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: item.itemController,
                                  decoration: _inputDecoration('Item Name'),
                                  style: const TextStyle(color: AppColors.textDark),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                              if (_lineItems.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.error),
                                  onPressed: () => _removeLineItem(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: item.qtyController,
                                  decoration: _inputDecoration('Qty'),
                                  style: const TextStyle(color: AppColors.textDark),
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: item.rateController,
                                  decoration: _inputDecoration('Rate'),
                                  style: const TextStyle(color: AppColors.textDark),
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.textLight),
                                  ),
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    item.amount.toStringAsFixed(2),
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              TextButton.icon(
                onPressed: _addLineItem,
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: const Text('Add Item', style: TextStyle(color: AppColors.primary)),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.textLight),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:', style: TextStyle(color: AppColors.textMedium)),
                        Text('₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textDark)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GST (18%):', style: TextStyle(color: AppColors.textMedium)),
                        Text('₹${gst.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textDark)),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.textLight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: AppColors.surface, strokeWidth: 2),
                        )
                      : const Text(
                          'Save Purchase',
                          style: TextStyle(color: AppColors.surface, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}