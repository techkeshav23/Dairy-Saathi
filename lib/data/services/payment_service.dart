import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/supabase_config.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  static final List<Map<String, dynamic>> _inMemory = [];

  Future<List<Map<String, dynamic>>> listPayments() async {
    try {
      if (SupabaseConfig.useSupabase) {
        final data = await Supabase.instance.client.from('payments').select();
        return List<Map<String, dynamic>>.from(data);
      } else {
        return List<Map<String, dynamic>>.from(_inMemory);
      }
    } catch (e) {
      throw Exception('Failed to list payments: $e');
    }
  }

  Future<bool> savePayment({
    required String partyName,
    required String direction,
    required double amount,
    required String mode,
    String note = '',
  }) async {
    final Map<String, dynamic> data = {
      'party_name': partyName,
      'direction': direction,
      'amount': amount,
      'mode': mode,
      'note': note,
    };

    try {
      if (SupabaseConfig.useSupabase) {
        await Supabase.instance.client.from('payments').insert({
          ...data,
          'user_id': Supabase.instance.client.auth.currentUser?.id,
        });
        return true;
      } else {
        _inMemory.add({
          ...data,
          'id': DateTime.now().millisecondsSinceEpoch,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true;
      }
    } catch (e) {
      throw Exception('Failed to save payment: $e');
    }
  }
}