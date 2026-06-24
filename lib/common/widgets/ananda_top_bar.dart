import 'package:flutter/material.dart';
import 'package:saathi/common/widgets/app_logo.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

/// White root-tab top bar: centered brand mark + version, with a dark wallet
/// chip on the right — exactly the Ananda Home/Report/More header.
class AnandaTopBar extends StatelessWidget {
  const AnandaTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault, 8, Dimensions.paddingSizeDefault, 10),
          child: Row(
            children: [
              const SizedBox(width: 40),
              const Spacer(),
              const AppLogo(size: 30),
              const SizedBox(width: 8),
              Text.rich(TextSpan(children: [
                TextSpan(text: 'v ', style: robotoRegular.copyWith(color: AppColors.textDark, fontSize: 14)),
                TextSpan(text: '1.0', style: robotoBold.copyWith(color: AppColors.textDark, fontSize: 14)),
              ])),
              const Spacer(),
              Container(
                width: 34, height: 22,
                decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
