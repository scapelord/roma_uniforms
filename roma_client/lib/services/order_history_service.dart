import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryService {
  final _client = Supabase.instance.client;

  // Fetch only MY orders
  Future<List<Map<String, dynamic>>> fetchMyOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    return await _client
        .from('orders')
        .select('*, order_items(*, products(*))') // Join items & products
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}
