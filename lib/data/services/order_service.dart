import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/supabase_config.dart';

class OrderService {
  static final List<Map<String, dynamic>> _localOrders = [];
  static final List<Map<String, dynamic>> _localOrderItems = [];

  Future<String?> placeOrder({
    required double total,
    required List<Map<String, dynamic>> items,
    String paymentMode = 'cod',
    String? screenshotUrl,
  }) async {
    try {
      if (SupabaseConfig.useSupabase) {
        // Use an RPC to insert the order and items atomically in a single transaction
        final response = await Supabase.instance.client.rpc(
          'place_order',
          params: {
            'total': total,
            'items': items,
            'payment_mode': paymentMode,
            'payment_screenshot': screenshotUrl,
          },
        );

        if (response == null) {
          throw Exception('Failed to place order: No response from server');
        }

        // If the RPC returns a map (e.g., the inserted row), extract the ID
        if (response is Map && response.containsKey('id')) {
          return response['id'].toString();
        }

        return response.toString();
      } else {
        final orderId = 'local_order_${DateTime.now().millisecondsSinceEpoch}';
        
        _localOrders.add({
          'id': orderId,
          'status': 'placed',
          'total': total,
          'created_at': DateTime.now().toIso8601String(),
        });

        for (final item in items) {
          _localOrderItems.add({
            'id': 'local_item_${DateTime.now().microsecondsSinceEpoch}',
            'order_id': orderId,
            'product_id': item['product_id'],
            'qty': item['qty'],
            'unit_price': item['unit_price'],
          });
        }

        return orderId;
      }
    } catch (e) {
      rethrow;
    }
  }
}