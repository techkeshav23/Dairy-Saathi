import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/repository.dart';
import 'package:my_order_pro/data/models/banner.dart';
import 'package:my_order_pro/data/models/category.dart';
import 'package:my_order_pro/data/models/ledger_entry.dart';
import 'package:my_order_pro/data/models/order.dart';
import 'package:my_order_pro/data/models/product.dart';

class SupabaseRepository implements Repository {
  final SupabaseClient _client = Supabase.instance.client;

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF1C6DD0);
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.tryParse(hex, radix: 16) ?? 0xFF1C6DD0);
  }

  /// Like [_parseColor] but returns null for empty/invalid — used by banners so an
  /// unset accent means "image only" (no colour tint), matching the admin toggle.
  Color? _parseColorOrNull(String? hex) {
    if (hex == null || hex.trim().isEmpty) return null;
    return _parseColor(hex);
  }

  Product _parseProduct(Map<String, dynamic> row) {
    final slabsData = row['price_slabs'] as List<dynamic>? ?? [];
    final slabs = slabsData.map((e) => PriceSlab(
      minQty: int.tryParse('${e['min_qty']}') ?? 1,
      pricePerUnit: double.tryParse('${e['price_per_unit']}') ?? 0,
    )).toList();
    
    slabs.sort((a, b) => a.minQty.compareTo(b.minQty));

    return Product(
      id: row['id'].toString(),
      name: row['name'] ?? '',
      brand: row['brand'] ?? '',
      categoryId: row['category_id'].toString(),
      imageUrl: row['image_url'] ?? '',
      unit: row['unit'] ?? '',
      mrp: double.tryParse('${row['mrp']}') ?? 0,
      slabs: slabs,
      moq: int.tryParse('${row['moq']}') ?? 1,
      stock: int.tryParse('${row['stock']}') ?? 0,
      isPopular: row['is_popular'] == true,
      isFeatured: row['is_featured'] == true,
      description: row['description'] ?? '',
      resalePriceValue: double.tryParse('${row['resale_price']}') ?? 0,
      eaPerKg: double.tryParse('${row['ea_per_kg']}') ?? 0,
    );
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final res = await _client.from('categories').select();
    return res.map((row) => CategoryModel(
      id: row['id'].toString(),
      name: row['name'] ?? '',
      icon: Icons.category_outlined,
      color: _parseColor(row['color_hex']),
      itemCount: int.tryParse('${row['item_count']}') ?? 0,
    )).toList();
  }

  @override
  Future<List<Product>> getProducts({String? categoryId, String? query}) async {
    var qb = _client.from('products').select('*, price_slabs(*)');
    
    if (categoryId != null && categoryId.isNotEmpty) {
      qb = qb.eq('category_id', categoryId);
    }
    
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim();
      qb = qb.or('name.ilike.%$q%,brand.ilike.%$q%');
    }
    
    final res = await qb.limit(300); // cap to avoid huge payloads / OOM
    return res.map((row) => _parseProduct(row)).toList();
  }

  @override
  Future<List<Product>> getFeatured() async {
    final res = await _client
        .from('products')
        .select('*, price_slabs(*)')
        .eq('is_featured', true)
        .limit(50);
    return res.map((row) => _parseProduct(row)).toList();
  }

  @override
  Future<List<Product>> getPopular() async {
    final res = await _client
        .from('products')
        .select('*, price_slabs(*)')
        .eq('is_popular', true)
        .limit(50);
    return res.map((row) => _parseProduct(row)).toList();
  }

  @override
  Future<Product?> getProduct(String id) async {
    final res = await _client
        .from('products')
        .select('*, price_slabs(*)')
        .eq('id', id)
        .maybeSingle();
        
    if (res == null) return null;
    return _parseProduct(res);
  }

  @override
  Future<List<BannerModel>> getBanners() async {
    // Only banners the distributor has toggled Active in the admin panel.
    final res = await _client.from('banners').select().eq('active', true);
    return res.map((row) => BannerModel(
      title: row['title'] ?? '',
      subtitle: row['subtitle'] ?? '',
      tag: row['tag'] ?? '',
      image: row['image'] ?? '',
      accent: _parseColorOrNull(row['accent_hex']),
    )).toList();
  }

  @override
  Future<List<LedgerEntry>> getLedger() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    
    final res = await _client
        .from('ledger_entries')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(200); // most-recent 200; paginate for older history
        
    return res.map((row) => LedgerEntry(
      id: row['id'].toString(),
      date: DateTime.tryParse('${row['created_at']}') ?? DateTime.now(),
      title: row['note'] ?? '',
      amount: double.tryParse('${row['amount']}') ?? 0,
      isDebit: row['type'] == 'debit',
    )).toList();
  }

  OrderStatus _parseStatus(dynamic s) {
    switch ('$s'.toLowerCase()) {
      case 'confirmed': return OrderStatus.confirmed;
      case 'packed': return OrderStatus.packed;
      case 'dispatched': return OrderStatus.dispatched;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.placed;
    }
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final res = await _client
        .from('orders')
        .select('id, status, total, created_at, '
            'order_items(product_id, qty, unit_price, products(name, unit, image_url))')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);

    return res.map<OrderModel>((row) {
      final itemsData = row['order_items'] as List<dynamic>? ?? [];
      final lines = itemsData.map((e) {
        final p = e['products'] as Map<String, dynamic>?;
        return OrderLine(
          productId: '${e['product_id'] ?? ''}',
          name: p?['name'] ?? 'Item',
          unit: p?['unit'] ?? '',
          imageUrl: p?['image_url'] ?? '',
          quantity: int.tryParse('${e['qty']}') ?? 1,
          unitPrice: double.tryParse('${e['unit_price']}') ?? 0,
        );
      }).toList();

      final total = double.tryParse('${row['total']}') ?? 0;
      final idStr = row['id'].toString();
      return OrderModel(
        id: idStr.length > 8 ? idStr.substring(0, 8).toUpperCase() : idStr,
        placedAt: DateTime.tryParse('${row['created_at']}') ?? DateTime.now(),
        lines: lines,
        subtotal: total,
        gst: 0,
        deliveryCharge: 0,
        total: total,
        savings: 0,
        status: _parseStatus(row['status']),
        paymentMode: PaymentMode.credit,
        address: '',
      );
    }).toList();
  }

  @override
  Future<String> requestOtp(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
      return '';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    final res = await _client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
    return res.session != null;
  }
}