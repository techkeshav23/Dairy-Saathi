import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saathi/common/widgets/app_logo.dart';
import 'package:saathi/common/widgets/custom_button.dart';
import 'package:saathi/helper/route_helper.dart';
import 'package:saathi/providers/auth_provider.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phone = TextEditingController();

  Future<void> _sendOtp() async {
    final phone = _phone.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.requestOtp(phone);
    if (!mounted) return;
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const AppLogo(size: 84, showWordmark: true),
              const SizedBox(height: 36),
              Text('Sign In', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
              const SizedBox(height: 6),
              Text('Login with your business mobile number',
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(color: AppColors.textMedium)),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // Country selector (demo, fixed to India)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text('+91 India', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down, color: AppColors.textMedium),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Mobile number (underline field)
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter Mobile Number',
                  hintStyle: robotoRegular.copyWith(color: AppColors.textLight),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              CustomButton(text: 'Sign In', isLoading: auth.loading, onPressed: _sendOtp),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Text.rich(
                TextSpan(
                  text: 'By signing up, I accept the ',
                  style: robotoRegular.copyWith(
                      color: AppColors.textLight, fontSize: Dimensions.fontSizeSmall),
                  children: [
                    TextSpan(text: 'Privacy Policy', style: robotoMedium.copyWith(
                        color: AppColors.link, fontSize: Dimensions.fontSizeSmall)),
                    const TextSpan(text: ' and '),
                    TextSpan(text: 'Terms', style: robotoMedium.copyWith(
                        color: AppColors.link, fontSize: Dimensions.fontSizeSmall)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Text('Or Continue with', style: robotoRegular.copyWith(color: AppColors.textMedium)),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Google sign-in (demo) — use mobile number')),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                ),
                icon: Text('G', style: robotoBold.copyWith(color: AppColors.link, fontSize: 18)),
                label: Text('Google Account',
                    style: robotoSemiBold.copyWith(color: AppColors.textDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
