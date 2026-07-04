import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/supabase_config.dart';

class InvoiceService {
  static final List<Map<String, dynamic>> _inMemoryInvoices = [];
  static final List<Map<String, dynamic>> _inMemoryInvoiceItems = [];

  Future<bool> saveInvoice({
    required String partyName,
    required double subtotal,
    required double gstAmount,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      if (SupabaseConfig.useSupabase) {
        final supabase = Supabase.instance.client;

        // Using an RPC call to ensure atomic master-detail insertion
        // and prevent partial writes if the items insertion fails.
        await supabase.rpc('create_sale_invoice', params: {
          'party_name': partyName,
          'subtotal': subtotal,
          'gst_amount': gstAmount,
          'total': total,
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'items': items.map((item) {
            return {
              'item_name': item['item_name'],
              'qty': item['qty'],
              'rate': item['rate'],
              'amount': item['amount'],
            };
          }).toList(),
        });

        return true;
      } else {
        final invoiceId = DateTime.now().millisecondsSinceEpoch;
        
        _inMemoryInvoices.add({
          'id': invoiceId,
          'party_name': partyName,
          'subtotal': subtotal,
          'gst_amount': gstAmount,
          'total': total,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });

        for (final item in items) {
          _inMemoryInvoiceItems.add({
            'id': DateTime.now().microsecondsSinceEpoch,
            'invoice_id': invoiceId,
            'item_name': item['item_name'],
            'qty': item['qty'],
            'rate': item['rate'],
            'amount': item['amount'],
          });
        }

        return true;
      }
    } on PostgrestException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }
}