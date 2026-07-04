import 'package:flutter/material.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';
import 'package:my_order_pro/data/services/payment_service.dart';

class PaymentInScreen extends StatefulWidget {
  const PaymentInScreen({super.key});

  @override
  State<PaymentInScreen> createState() => _PaymentInScreenState();
}

class _PaymentInScreenState extends State<PaymentInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partyNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedMode = 'Cash';
  bool _isLoading = false;
  
  final List<String> _paymentModes = const ['Cash', 'UPI', 'Bank', 'Cheque'];

  @override
  void dispose() {
    _partyNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text.trim());
      final success = await PaymentService().savePayment(
        partyName: _partyNameController.text.trim(),
        direction: 'in',
        amount: amount,
        mode: _selectedMode,
        note: _noteController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment received successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        
        _formKey.currentState!.reset();
        _partyNameController.clear();
        _amountController.clear();
        _noteController.clear();
        setState(() {
          _selectedMode = 'Cash';
        });
        
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save payment'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid amount entered'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Payment In', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: IgnorePointer(
          ignoring: _isLoading,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              children: [
                Text(
                  'Record Received Payment',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  'Enter details of the payment received from a party.',
                  style: robotoRegular.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                
                TextFormField(
                  controller: _partyNameController,
                  style: robotoRegular.copyWith(color: AppColors.textDark),
                  decoration: InputDecoration(
                    labelText: 'Received From (Party Name)',
                    labelStyle: robotoRegular.copyWith(color: AppColors.textMedium),
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: BorderSide(
                        color: AppColors.textLight.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter party name';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: robotoBold.copyWith(color: AppColors.textDark, fontSize: Dimensions.fontSizeLarge),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: robotoRegular.copyWith(color: AppColors.textMedium),
                    prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: BorderSide(
                        color: AppColors.textLight.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount greater than 0';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                
                DropdownButtonFormField<String>(
                  initialValue: _selectedMode,
                  dropdownColor: AppColors.surface,
                  style: robotoRegular.copyWith(color: AppColors.textDark, fontSize: Dimensions.fontSizeLarge),
                  decoration: InputDecoration(
                    labelText: 'Payment Mode',
                    labelStyle: robotoRegular.copyWith(color: AppColors.textMedium),
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: BorderSide(
                        color: AppColors.textLight.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                    ),
                  ),
                  items: _paymentModes.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMode = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  style: robotoRegular.copyWith(color: AppColors.textDark),
                  decoration: InputDecoration(
                    labelText: 'Note (Optional)',
                    labelStyle: robotoRegular.copyWith(color: AppColors.textMedium),
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Icon(Icons.note_alt_outlined, color: AppColors.primary),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: BorderSide(
                        color: AppColors.textLight.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Save Payment',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}