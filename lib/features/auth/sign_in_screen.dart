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

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phone = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    final phone = _phone.text.trim();
    final auth = context.read<AuthProvider>();
    
    // Unfocus keyboard
    FocusScope.of(context).unfocus();
    
    final err = await auth.requestOtp(phone);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send OTP: $err'), backgroundColor: Colors.red),
      );
      return;
    }
    Navigator.pushNamed(context, RouteHelper.verifyOtp, arguments: phone);
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

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
                  Image.asset(
                    'assets/brand/logo.png',
                    width: 260,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const AppLogo(size: 84, showWordmark: true),
                  ),
                  const SizedBox(height: 28),
                  Text('Welcome Back', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
                  const SizedBox(height: 8),
                  Text('Sign in to manage your wholesale business',
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(color: AppColors.textMedium, fontSize: Dimensions.fontSizeDefault)),
                  const SizedBox(height: 40),

                  // Mobile number field with integrated country code
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                        return 'Enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Mobile Number',
                      hintStyle: robotoRegular.copyWith(color: AppColors.textLight),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text('+91', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                            const SizedBox(width: 8),
                            Container(width: 1, height: 24, color: AppColors.border),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  CustomButton(
                    text: 'Get OTP', 
                    isLoading: auth.loading, 
                    onPressed: _sendOtp,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text.rich(
                    TextSpan(
                      text: 'By signing in, I accept the ',
                      style: robotoRegular.copyWith(
                          color: AppColors.textLight, fontSize: Dimensions.fontSizeSmall),
                      children: [
                        TextSpan(text: 'Privacy Policy', style: robotoMedium.copyWith(
                            color: AppColors.primary, fontSize: Dimensions.fontSizeSmall)),
                        const TextSpan(text: ' and '),
                        TextSpan(text: 'Terms', style: robotoMedium.copyWith(
                            color: AppColors.primary, fontSize: Dimensions.fontSizeSmall)),
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