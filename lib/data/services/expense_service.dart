import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/supabase_config.dart';
import 'dart:developer';

class ExpenseService {
  static final List<Map<String, dynamic>> _inMemory = [];

  Future<bool> saveExpense({
    required String category,
    required double amount,
    String note = '',
  }) async {
    try {
      final Map<String, dynamic> data = {
        'category': category,
        'amount': amount,
        'note': note,
      };

      if (SupabaseConfig.useSupabase) {
        await Supabase.instance.client.from('expenses').insert({
          ...data,
          'user_id': Supabase.instance.client.auth.currentUser?.id,
        });
        return true;
      } else {
        _inMemory.add(data);
        return true;
      }
    } catch (e, st) {
      log('Error saving expense: $e\n$st');
      return false;
    }
  }
}