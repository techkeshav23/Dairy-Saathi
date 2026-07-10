import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/app_logo.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _shop = TextEditingController();
  final _owner = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _phone = TextEditingController();
  final _area = TextEditingController();
  final _idNumber = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _obscureConfirm = true;
  String _idType = 'gst'; // 'gst' | 'pan' | 'aadhaar'

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final err = await auth.signUp(
      email: _email.text.trim(),
      password: _password.text,
      shopName: _shop.text.trim(),
      ownerName: _owner.text.trim(),
      phone: _phone.text.trim(),
      idType: _idType,
      idNumber: _idNumber.text.trim().toUpperCase(),
      area: _area.text.trim(),
    );
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: err.startsWith('Account created') ? AppColors.success : AppColors.error),
      );
      if (err.startsWith('Account created')) Navigator.pop(context); // go back to sign in
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, RouteHelper.dashboard, (r) => false);
  }

  @override
  void dispose() {
    _shop.dispose();
    _owner.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _phone.dispose();
    _area.dispose();
    _idNumber.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix, String? prefixText}) => InputDecoration(
        hintText: hint,
        hintStyle: robotoRegular.copyWith(color: AppColors.textLight),
        prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
        prefixText: prefixText,
        prefixStyle: robotoBold.copyWith(color: AppColors.textDark, fontSize: Dimensions.fontSizeDefault),
        counterText: '',
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), borderSide: const BorderSide(color: Colors.red)),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 0, Dimensions.paddingSizeLarge, Dimensions.paddingSizeLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: const AppLogo(size: 64)),
                const SizedBox(height: 20),
                Text('Create retailer account', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
                const SizedBox(height: 6),
                Text('Register your shop and start ordering at wholesale rates.',
                    style: robotoRegular.copyWith(color: AppColors.textMedium, fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(height: 26),

                _label('Shop Name *'),
                TextFormField(controller: _shop, textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your shop name' : null,
                    decoration: _decoration('Shop / business name', Icons.storefront_outlined)),
                const SizedBox(height: 14),

                _label('Owner Name *'),
                TextFormField(controller: _owner, textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter the owner name' : null,
                    decoration: _decoration('Your name', Icons.person_outline)),
                const SizedBox(height: 14),

                _label('Email *'),
                TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter your email';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Enter a valid email';
                      return null;
                    },
                    decoration: _decoration('Enter email address', Icons.mail_outline)),
                const SizedBox(height: 14),

                _label('Password *'),
                TextFormField(controller: _password, obscureText: _obscure,
                    validator: _validatePassword,
                    decoration: _decoration('Create a password', Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textLight, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ))),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 2),
                  child: Text('8+ characters with uppercase, lowercase & a number',
                      style: robotoRegular.copyWith(color: AppColors.textLight, fontSize: Dimensions.fontSizeExtraSmall)),
                ),
                const SizedBox(height: 14),

                _label('Confirm Password *'),
                TextFormField(controller: _confirm, obscureText: _obscureConfirm,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Re-enter your password';
                      if (v != _password.text) return 'Passwords do not match';
                      return null;
                    },
                    decoration: _decoration('Re-enter your password', Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textLight, size: 20),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ))),
                const SizedBox(height: 14),

                _label('Phone *'),
                TextFormField(controller: _phone, keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 10) return 'Enter a valid 10-digit mobile number';
                      return null;
                    },
                    decoration: _decoration('10-digit mobile', Icons.phone_outlined, prefixText: '+91 ')),
                const SizedBox(height: 14),

                _label('Area (optional)'),
                TextFormField(controller: _area, decoration: _decoration('City / area', Icons.location_on_outlined)),
                const SizedBox(height: 14),

                _label('ID Proof *'),
                Row(children: [
                  _idChip('GST', 'gst'),
                  const SizedBox(width: 8),
                  _idChip('PAN', 'pan'),
                  const SizedBox(width: 8),
                  _idChip('Aadhaar', 'aadhaar'),
                ]),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _idNumber,
                  textCapitalization: _idType == 'aadhaar' ? TextCapitalization.none : TextCapitalization.characters,
                  keyboardType: _idType == 'aadhaar' ? TextInputType.number : TextInputType.text,
                  inputFormatters: _idFormatters,
                  validator: _validateId,
                  decoration: _decoration(_idHint, Icons.badge_outlined),
                ),
                const SizedBox(height: 28),

                CustomButton(text: 'Create Account', isLoading: auth.loading, onPressed: _signUp),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text.rich(TextSpan(
                      text: 'Already have an account? ',
                      style: robotoRegular.copyWith(color: AppColors.textMedium),
                      children: [TextSpan(text: 'Sign In', style: robotoBold.copyWith(color: AppColors.primary))],
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 2),
        child: Text(t, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: AppColors.textMedium)),
      );

  String get _idHint => _idType == 'gst'
      ? '15-character GSTIN'
      : _idType == 'pan'
          ? '10-character PAN (e.g. ABCDE1234F)'
          : '12-digit Aadhaar number';

  // Per-type input rules: cap the length and restrict characters (uppercase alphanumeric
  // for GST/PAN, digits only for Aadhaar) so no invalid/overlong value can be typed.
  List<TextInputFormatter> get _idFormatters {
    final upper = TextInputFormatter.withFunction(
        (oldV, newV) => newV.copyWith(text: newV.text.toUpperCase()));
    switch (_idType) {
      case 'aadhaar':
        return [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)];
      case 'pan':
        return [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), LengthLimitingTextInputFormatter(10), upper];
      case 'gst':
      default:
        return [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), LengthLimitingTextInputFormatter(15), upper];
    }
  }

  Widget _idChip(String label, String value) {
    final selected = _idType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _idType = value;
          _idNumber.clear();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(label,
              style: robotoMedium.copyWith(
                  color: selected ? Colors.white : AppColors.textMedium, fontSize: Dimensions.fontSizeSmall)),
        ),
      ),
    );
  }

  String? _validatePassword(String? v) {
    final s = v ?? '';
    if (s.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[a-z]').hasMatch(s)) return 'Add a lowercase letter';
    if (!RegExp(r'[A-Z]').hasMatch(s)) return 'Add an uppercase letter';
    if (!RegExp(r'\d').hasMatch(s)) return 'Add a number';
    return null;
  }

  String? _validateId(String? v) {
    final s = (v ?? '').trim().toUpperCase();
    if (s.isEmpty) {
      return _idType == 'gst'
          ? 'Enter your GSTIN'
          : _idType == 'pan'
              ? 'Enter your PAN'
              : 'Enter your Aadhaar number';
    }
    switch (_idType) {
      case 'gst':
        if (!RegExp(r'^[0-9A-Z]{15}$').hasMatch(s)) return 'GSTIN must be 15 characters';
        break;
      case 'pan':
        if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(s)) return 'Invalid PAN (e.g. ABCDE1234F)';
        break;
      case 'aadhaar':
        if (!RegExp(r'^[0-9]{12}$').hasMatch(s)) return 'Aadhaar must be 12 digits';
        break;
    }
    return null;
  }
}
