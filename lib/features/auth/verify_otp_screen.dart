import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:saathi/common/widgets/custom_button.dart';
import 'package:saathi/helper/route_helper.dart';
import 'package:saathi/providers/auth_provider.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phone;
  const VerifyOtpScreen({super.key, required this.phone});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String _otp = '';

  Future<void> _verify() async {
    if (_otp.length != 4) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(widget.phone, _otp);
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
          context, RouteHelper.dashboard, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Verify OTP', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
            const SizedBox(height: 6),
            Text.rich(TextSpan(
              text: 'Enter the 4-digit code sent to ',
              style: robotoRegular.copyWith(color: AppColors.textMedium),
              children: [
                TextSpan(text: '+91 ${widget.phone}',
                    style: robotoSemiBold.copyWith(color: AppColors.textDark)),
              ],
            )),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            PinCodeTextField(
              appContext: context,
              length: 4,
              autoFocus: true,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              textStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                fieldHeight: 58,
                fieldWidth: 58,
                activeColor: AppColors.primary,
                selectedColor: AppColors.primary,
                inactiveColor: AppColors.border,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.white,
              ),
              enableActiveFill: true,
              onChanged: (v) => _otp = v,
              onCompleted: (v) {
                _otp = v;
                _verify();
              },
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            // Demo helper — surfaces the auto-generated OTP.
            if (auth.lastOtp != null)
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Demo mode: your OTP is ${auth.lastOtp}',
                          style: robotoMedium.copyWith(
                              color: AppColors.accent, fontSize: Dimensions.fontSizeSmall)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            CustomButton(text: 'Verify & Continue', isLoading: auth.loading, onPressed: _verify),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Center(
              child: TextButton(
                onPressed: () => context.read<AuthProvider>().requestOtp(widget.phone),
                child: Text('Resend OTP', style: robotoMedium.copyWith(color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
