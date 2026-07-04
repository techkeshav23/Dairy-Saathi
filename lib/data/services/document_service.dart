import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/supabase_config.dart';

/// Persists generic business documents (Estimate, Sale Order, Delivery Challan,
/// Credit/Debit Note, Purchase Order) to the `documents` table (schema_v8), or an
/// in-memory list when Supabase isn't configured.
class DocumentService {
  static final List<Map<String, dynamic>> _inMemory = [];

  Future<bool> saveDocument({
    required String docType,
    required String docNo,
    required String partyName,
    String partyGstin = '',
    required DateTime date,
    required double subtotal,
    required double cgst,
    required double sgst,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    final row = {
      'doc_type': docType,
      'doc_no': docNo,
      'party_name': partyName,
      'party_gstin': partyGstin,
      'doc_date': date.toIso8601String().split('T').first,
      'subtotal': subtotal,
      'cgst': cgst,
      'sgst': sgst,
      'total': total,
      'items': items,
    };
    try {
      if (SupabaseConfig.useSupabase) {
        await Supabase.instance.client.from('documents').insert({
          ...row,
          'user_id': Supabase.instance.client.auth.currentUser?.id,
        });
      } else {
        _inMemory.add({...row, 'created_at': DateTime.now().toIso8601String()});
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listDocuments({String? docType}) async {
    try {
      if (SupabaseConfig.useSupabase) {
        var q = Supabase.instance.client.from('documents').select();
        if (docType != null) {
          q = q.eq('doc_type', docType);
        }
        final res = await q;
        return List<Map<String, dynamic>>.from(res);
      }
      if (docType != null) {
        return _inMemory.where((d) => d['doc_type'] == docType).toList();
      }
      return List<Map<String, dynamic>>.from(_inMemory);
    } catch (e) {
      rethrow;
    }
  }
}