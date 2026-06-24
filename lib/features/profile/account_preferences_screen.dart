import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saathi/helper/route_helper.dart';
import 'package:saathi/providers/auth_provider.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

class AccountPreferencesScreen extends StatelessWidget {
  const AccountPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final address = (user?.address.isNotEmpty ?? false)
        ? user!.address
        : 'Main Bazaar, Chandpur, Bijnor, Uttar Pradesh, India, 246725';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Account & Preferences', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge))),
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                // Profile
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 96, height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryLight,
                                border: Border.all(color: AppColors.primary, width: 2.5),
                              ),
                              child: Center(
                                child: Text(
                                  (user?.shopName.isNotEmpty ?? false) ? user!.shopName[0].toUpperCase() : 'D',
                                  style: robotoBold.copyWith(color: AppColors.primary, fontSize: 38),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0, bottom: 0,
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Retailer', style: robotoMedium.copyWith(
                                    color: AppColors.link, fontSize: Dimensions.fontSizeSmall)),
                                const SizedBox(height: 2),
                                Text(user?.shopName ?? 'My Kirana Store',
                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                                const SizedBox(height: 2),
                                Text('+91 - ${user?.phone ?? "9000000000"}',
                                    style: robotoRegular.copyWith(color: AppColors.textLight, fontSize: Dimensions.fontSizeDefault)),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pushNamed(context, RouteHelper.profile),
                            child: const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFECECEC)),
                _detailRow(Icons.location_on_outlined, 'Address', address, isLink: false),
                const Divider(height: 1, color: Color(0xFFECECEC)),
                _detailRow(Icons.my_location_outlined, 'Coordinates', '29.1247315, 78.2773148', isLink: true),
                const Divider(height: 1, color: Color(0xFFECECEC)),
                _simpleRow(context, Icons.phonelink_setup_outlined, 'Device Manager'),
                const Divider(height: 1, color: Color(0xFFECECEC)),
                _simpleRow(context, Icons.find_in_page_outlined, 'Offline Data'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String heading, String value, {required bool isLink}) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(heading, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                const SizedBox(height: 3),
                Text(value, style: robotoRegular.copyWith(
                    color: isLink ? AppColors.link : const Color(0xFF3A3A3A),
                    fontSize: Dimensions.fontSizeDefault, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 20),
        ],
      ),
    );
  }

  Widget _simpleRow(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label — demo'))),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(child: Text(label, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault))),
            const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 20),
          ],
        ),
      ),
    );
  }
}
