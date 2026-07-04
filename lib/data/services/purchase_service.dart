import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/supabase_config.dart';

class PurchaseException implements Exception {
  final String message;
  PurchaseException(this.message);

  @override
  String toString() => 'PurchaseException: $message';
}

class PurchaseService {
  static final List<Map<String, dynamic>> _mockPurchases = [];
  static final List<Map<String, dynamic>> _mockPurchaseItems = [];

  Future<bool> savePurchase({
    required String supplierName,
    String billNo = '',
    required double subtotal,
    required double gstAmount,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      if (SupabaseConfig.useSupabase) {
        final purchaseData = {
          'supplier_name': supplierName,
          'bill_no': billNo,
          'subtotal': subtotal,
          'gst_amount': gstAmount,
          'total': total,
          'created_at': DateTime.now().toIso8601String(),
        };

        final itemsData = items.map((item) {
          return {
            'item_name': item['item_name'] ?? item['name'] ?? '',
            'quantity': item['quantity'] ?? 0,
            'rate': item['rate'] ?? item['price'] ?? 0.0,
            'total': item['total'] ?? 0.0,
          };
        }).toList();

        // Use an RPC call to ensure transactional integrity for master-detail records
        await Supabase.instance.client.rpc(
          'create_purchase_with_items',
          params: {
            'purchase_data': purchaseData,
            'items_data': itemsData,
          },
        );

        return true;
      } else {
        final purchaseId = DateTime.now().millisecondsSinceEpoch.toString();
        final purchaseData = {
          'id': purchaseId,
          'supplier_name': supplierName,
          'bill_no': billNo,
          'subtotal': subtotal,
          'gst_amount': gstAmount,
          'total': total,
          'created_at': DateTime.now().toIso8601String(),
        };
        
        _mockPurchases.add(purchaseData);

        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          _mockPurchaseItems.add({
            'id': '${DateTime.now().millisecondsSinceEpoch}_$i',
            'purchase_id': purchaseId,
            'item_name': item['item_name'] ?? item['name'] ?? '',
            'quantity': item['quantity'] ?? 0,
            'rate': item['rate'] ?? item['price'] ?? 0.0,
            'total': item['total'] ?? 0.0,
          });
        }
        return true;
      }
    } on PostgrestException catch (e) {
      throw PurchaseException(e.message);
    } catch (e) {
      throw PurchaseException(e.toString());
    }
  }
}