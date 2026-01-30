import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roma_shared/models/product_model.dart';

class AdminSupabaseService {
  final _client = Supabase.instance.client;

  // 1. FETCH ALL (The Grid)
  Future<List<Product>> fetchAllProducts() async {
    final response = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false); // Newest first
    
    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  // 2. DELETE (Red Flag)
  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  // 3. ADD / UPDATE (Pit Stop Adjustment)
  Future<void> saveProduct({
    String? id, // If null, we create new. If exists, we update.
    required String name,
    required String description,
    required String category,
    required double price,
    double? salePrice,
    required int stockLevel,
    required List<String> images,
  }) async {
    final data = {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'sale_price': salePrice,
      'stock_level': stockLevel,
      'images': images,
      'status': stockLevel == 0 ? 'out_of_stock' : 'in_stock',
    };

    if (id == null) {
      // CREATE
      await _client.from('products').insert(data);
    } else {
      // UPDATE
      await _client.from('products').update(data).eq('id', id);
    }
  }

  // 4. UPLOAD IMAGE (The Fuel Hose)
  Future<String> uploadImage(File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'uploads/$fileName';

    await _client.storage.from('products').upload(path, file);
    
    // Get the Public URL
    return _client.storage.from('products').getPublicUrl(path);
  }

  // FETCH ALL ORDERS (Admin View)
  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    return await _client
        .from('orders')
        .select('*, profiles(full_name, phone_number), order_items(*, products(name))')
        .order('created_at', ascending: false);
  }

  // UPDATE STATUS (Dispatch)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _client.from('orders').update({'status': newStatus}).eq('id', orderId);
  }
}
