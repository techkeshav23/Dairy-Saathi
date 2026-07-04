import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phone;
  const VerifyOtpScreen({super.key, required this.phone});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String _otp = '';

  Future<void> _verify() async {
    if (_otp.length != 6) return;
    
    // Unfocus keyboard
    FocusScope.of(context).unfocus();
    
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(widget.phone, _otp);
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
          context, RouteHelper.dashboard, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Verify OTP', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
              const SizedBox(height: 8),
              Text.rich(TextSpan(
                text: 'Enter the 6-digit code sent to ',
                style: robotoRegular.copyWith(color: AppColors.textMedium, fontSize: Dimensions.fontSizeDefault),
                children: [
                  TextSpan(text: '+91 ${widget.phone}',
                      style: robotoSemiBold.copyWith(color: AppColors.textDark)),
                ],
              )),
              const SizedBox(height: 40),
              
              PinCodeTextField(
                appContext: context,
                length: 6,
                autoFocus: true,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                textStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  fieldHeight: 55,
                  fieldWidth: 48,
                  activeColor: AppColors.primary,
                  selectedColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  activeFillColor: AppColors.card,
                  inactiveFillColor: AppColors.card,
                  selectedFillColor: AppColors.card,
                ),
                enableActiveFill: true,
                onChanged: (v) => _otp = v,
                onCompleted: (v) {
                  _otp = v;
                  _verify();
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              
              // Demo helper — surfaces the auto-generated OTP.
              if (auth.lastOtp != null)
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: AppColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Demo mode: your OTP is ${auth.lastOtp}',
                            style: robotoMedium.copyWith(
                                color: AppColors.accent, fontSize: Dimensions.fontSizeDefault)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),
              
              CustomButton(
                text: 'Verify & Continue', 
                isLoading: auth.loading, 
                onPressed: _verify,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              
              Center(
                child: TextButton(
                  onPressed: auth.loading ? null : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await context.read<AuthProvider>().requestOtp(widget.phone);
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('OTP resent successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: Text('Resend OTP', style: robotoMedium.copyWith(
                    color: auth.loading ? AppColors.textLight : AppColors.primary, 
                    fontSize: Dimensions.fontSizeLarge,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}