import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/supabase_config.dart';

class ItemService {
  static final List<Map<String, dynamic>> _inMemoryProducts = [];

  Future<bool> addItem({
    required String name,
    required String brand,
    required double mrp,
    int moq = 1,
    int stock = 0,
    String categoryId = '',
    String imageUrl = '',
    String unit = '',
    bool isPopular = false,
    bool isFeatured = false,
    String description = '',
  }) async {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    
    final Map<String, dynamic> productData = {
      'id': id,
      'name': name,
      'brand': brand,
      'mrp': mrp,
      'base_price': mrp,
      'moq': moq,
      'stock': stock,
      'category_id': categoryId,
      'image_url': imageUrl,
      'unit': unit,
      'is_popular': isPopular,
      'is_featured': isFeatured,
      'description': description,
      'slabs': [],
    };

    try {
      if (SupabaseConfig.useSupabase) {
        await Supabase.instance.client.from('products').insert(productData);
        return true;
      } else {
        _inMemoryProducts.add(productData);
        return true;
      }
    } on PostgrestException {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> listItems() async {
    if (SupabaseConfig.useSupabase) {
      final response = await Supabase.instance.client.from('products').select();
      return List<Map<String, dynamic>>.from(response);
    } else {
      return List<Map<String, dynamic>>.from(_inMemoryProducts);
    }
  }
}