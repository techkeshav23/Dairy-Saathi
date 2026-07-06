import 'package:flutter/material.dart';
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
  final _phone = TextEditingController();
  final _area = TextEditingController();
  final _gst = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

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
      gstin: _gst.text.trim(),
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
    _phone.dispose();
    _area.dispose();
    _gst.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: robotoRegular.copyWith(color: AppColors.textLight),
        prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
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
                    decoration: _decoration('e.g. Sharma Kirana Store', Icons.storefront_outlined)),
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
                    decoration: _decoration('you@shop.com', Icons.mail_outline)),
                const SizedBox(height: 14),

                _label('Password *'),
                TextFormField(controller: _password, obscureText: _obscure,
                    validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                    decoration: _decoration('Create a password', Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textLight, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ))),
                const SizedBox(height: 14),

                _label('Phone (optional)'),
                TextFormField(controller: _phone, keyboardType: TextInputType.phone,
                    decoration: _decoration('10-digit mobile', Icons.phone_outlined)),
                const SizedBox(height: 14),

                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Area'),
                    TextFormField(controller: _area, decoration: _decoration('City / area', Icons.location_on_outlined)),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('GSTIN'),
                    TextFormField(controller: _gst, textCapitalization: TextCapitalization.characters, decoration: _decoration('Optional', Icons.receipt_long_outlined)),
                  ])),
                ]),
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
}
