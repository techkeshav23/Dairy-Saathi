import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_order_pro/util/app_colors.dart';

class OnlineStoreScreen extends StatefulWidget {
  const OnlineStoreScreen({super.key});

  @override
  State<OnlineStoreScreen> createState() => _OnlineStoreScreenState();
}

class _OnlineStoreScreenState extends State<OnlineStoreScreen> {
  bool _isStoreOnline = true;
  bool _showPrices = true;
  bool _acceptOrders = true;

  final String _storeLink = 'myorderpro.store/my_shop';

  Future<void> _copyStoreLink() async {
    await Clipboard.setData(ClipboardData(text: _storeLink));
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Store link copied to clipboard',
          style: TextStyle(color: AppColors.surface),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'My Online Store',
          style: TextStyle(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.surface),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'Store Settings',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              color: AppColors.card,
              elevation: 2.0,
              shadowColor: AppColors.textDark.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    title: Text(
                      'Store Link',
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 14.0,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _storeLink,
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: _copyStoreLink,
                      tooltip: 'Copy Link',
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: AppColors.textLight.withValues(alpha: 0.2),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    activeThumbColor: AppColors.primary,
                    title: Text(
                      'Store Online',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Make your store visible to customers',
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 13.0,
                      ),
                    ),
                    value: _isStoreOnline,
                    onChanged: (bool value) {
                      setState(() {
                        _isStoreOnline = value;
                      });
                    },
                  ),
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: AppColors.textLight.withValues(alpha: 0.2),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    activeThumbColor: AppColors.primary,
                    title: Text(
                      'Show Prices to Customers',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Display item prices (e.g. ₹ 199.00)',
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 13.0,
                      ),
                    ),
                    value: _showPrices,
                    onChanged: (bool value) {
                      setState(() {
                        _showPrices = value;
                      });
                    },
                  ),
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: AppColors.textLight.withValues(alpha: 0.2),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    activeThumbColor: AppColors.primary,
                    title: Text(
                      'Accept Online Orders',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Allow customers to place orders directly',
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 13.0,
                      ),
                    ),
                    value: _acceptOrders,
                    onChanged: (bool value) {
                      setState(() {
                        _acceptOrders = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}