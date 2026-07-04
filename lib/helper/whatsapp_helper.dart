import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  WhatsAppHelper._();

  static Future<bool> sendPaymentReminder({
    required String phone,
    required String partyName,
    required double amount,
    String shopName = 'MY ORDER PRO',
  }) async {
    String normalizedPhone = phone.replaceAll(RegExp(r'\D'), '');
    
    if (normalizedPhone.startsWith('0')) {
      normalizedPhone = normalizedPhone.substring(1);
    }
    if (normalizedPhone.length == 10) {
      normalizedPhone = '91$normalizedPhone';
    }

    final String formattedAmount = amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
    final String message = 'Namaste $partyName, this is a friendly reminder from $shopName. Your outstanding balance is ₹$formattedAmount. Kindly clear it at your earliest. Thank you.';
    final String encodedMessage = Uri.encodeComponent(message);

    final Uri url = Uri.parse('https://wa.me/$normalizedPhone?text=$encodedMessage');

    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> callNumber(String phone) async {
    final String normalizedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri url = Uri.parse('tel:$normalizedPhone');

    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}