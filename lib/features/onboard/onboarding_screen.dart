import 'package:flutter/material.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/helper/route_helper.dart';
import 'package:my_order_pro/util/app_colors.dart';
import 'package:my_order_pro/util/app_constants.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Slide {
  final IconData icon;
  final String title;
  final String body;
  const _Slide(this.icon, this.title, this.body);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(Icons.inventory_2_outlined, 'Wholesale rates, direct',
        'Thousands of FMCG products at factory-direct wholesale prices — no middleman markup.'),
    _Slide(Icons.trending_down_rounded, 'Buy more, save more',
        'Bulk price slabs auto-apply. The bigger your order, the lower your per-unit cost.'),
    _Slide(Icons.account_balance_wallet_outlined, 'Pay later on Khata',
        'Trusted retailers get credit. Order today, settle your khata in 15 days.'),
    _Slide(Icons.local_shipping_outlined, 'Fast doorstep delivery',
        'Track every order live and get stock delivered straight to your shop.'),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardSeen, true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, RouteHelper.signIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('Skip', style: robotoMedium.copyWith(color: AppColors.textMedium)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180, height: 180,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight, shape: BoxShape.circle),
                          child: Icon(s.icon, size: 86, color: AppColors.primary),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtremeLarge),
                        Text(s.title, textAlign: TextAlign.center,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Text(s.body, textAlign: TextAlign.center,
                            style: robotoRegular.copyWith(
                                color: AppColors.textMedium,
                                fontSize: Dimensions.fontSizeLarge, height: 1.45)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8, height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: CustomButton(
                text: isLast ? 'Get Started' : 'Next',
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
