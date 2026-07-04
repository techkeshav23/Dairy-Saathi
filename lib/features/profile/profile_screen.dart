import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_order_pro/common/widgets/custom_button.dart';
import 'package:my_order_pro/common/widgets/custom_text_field.dart';
import 'package:my_order_pro/data/models/user.dart';
import 'package:my_order_pro/providers/auth_provider.dart';
import 'package:my_order_pro/util/dimensions.dart';
import 'package:my_order_pro/util/styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _shop;
  late final TextEditingController _address;
  late final TextEditingController _gstin;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _shop = TextEditingController(text: user?.shopName ?? '');
    _address = TextEditingController(text: user?.address ?? '');
    _gstin = TextEditingController(text: user?.gstin ?? '');
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    await auth.updateProfile(UserModel(
      name: _name.text.trim(),
      shopName: _shop.text.trim(),
      phone: auth.user?.phone ?? '',
      address: _address.text.trim(),
      gstin: _gstin.text.trim(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _name.dispose();
    _shop.dispose();
    _address.dispose();
    _gstin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        children: [
          CustomTextField(hint: 'Owner name', label: 'Owner Name', controller: _name, prefixIcon: Icons.person_outline),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          CustomTextField(hint: 'Shop / business name', label: 'Shop Name', controller: _shop, prefixIcon: Icons.storefront_outlined),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          CustomTextField(
            hint: 'Mobile number', label: 'Mobile Number',
            controller: TextEditingController(text: '+91 ${user?.phone ?? ""}'),
            readOnly: true, prefixIcon: Icons.phone_android,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          CustomTextField(
            hint: 'Shop address', label: 'Delivery Address',
            controller: _address, maxLines: 3, prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          CustomTextField(hint: 'GSTIN (optional)', label: 'GSTIN', controller: _gstin, prefixIcon: Icons.badge_outlined),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          CustomButton(text: 'Save Changes', onPressed: _save, icon: Icons.check),
        ],
      ),
    );
  }
}
