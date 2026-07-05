import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/app_logo.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final err = await auth.signIn(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, RouteHelper.homeFor(auth.isDistributor), (r) => false);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 88, showWordmark: true),
                  const SizedBox(height: 32),
                  Text('Welcome Back', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
                  const SizedBox(height: 8),
                  Text('Sign in to reorder your daily stock',
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(color: AppColors.textMedium, fontSize: Dimensions.fontSizeDefault)),
                  const SizedBox(height: 36),

                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Enter a valid email';
                      return null;
                    },
                    decoration: _decoration('Email address', Icons.mail_outline),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                    onFieldSubmitted: (_) => _signIn(),
                    decoration: _decoration('Password', Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textLight, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        )),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  CustomButton(text: 'Sign In', isLoading: auth.loading, onPressed: _signIn),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("New here? ", style: robotoRegular.copyWith(color: AppColors.textMedium)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, RouteHelper.signUp),
                        child: Text('Create an account', style: robotoBold.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text.rich(
                    TextSpan(
                      text: 'By signing in, you accept the ',
                      style: robotoRegular.copyWith(color: AppColors.textLight, fontSize: Dimensions.fontSizeSmall),
                      children: [
                        TextSpan(text: 'Privacy Policy', style: robotoMedium.copyWith(color: AppColors.primary, fontSize: Dimensions.fontSizeSmall)),
                        const TextSpan(text: ' and '),
                        TextSpan(text: 'Terms', style: robotoMedium.copyWith(color: AppColors.primary, fontSize: Dimensions.fontSizeSmall)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
