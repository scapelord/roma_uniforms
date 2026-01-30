import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roma_shared/models/product_model.dart';

class ProductRepository {
  final SupabaseClient _client;

  ProductRepository(this._client);

  Future<List<Product>> fetchProducts() async {
    try {
      final data = await _client
          .from('products')
          .select()
          .order('name', ascending: true);

      return (data as List<dynamic>)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      // Return empty list on error for now, or rethrow
      return [];
    }
  }

  // Fetch by Category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final data = await _client
          .from('products')
          .select()
          .eq('category', category)
          .order('name', ascending: true);

      return (data as List<dynamic>)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
