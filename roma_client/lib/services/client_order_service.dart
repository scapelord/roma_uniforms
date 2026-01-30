import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roma_client/features/cart/cart_provider.dart';

class ClientOrderService {
  final _client = Supabase.instance.client;

  Future<void> placeOrder({
    required List<CartItem> items,
    required double totalAmount,
    required double deliveryCost,
    required String deliveryAddress,
    required String regionName,
    required String paymentRef,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // 1. Create the Order Record
    final orderResponse = await _client.from('orders').insert({
      'user_id': user.id,
      'status': 'pending',
      'total_amount': totalAmount,
      'delivery_cost': deliveryCost,
      'delivery_address': "$regionName - $deliveryAddress",
      'payment_reference': paymentRef,
    }).select().single();

    final orderId = orderResponse['id'];

    // 2. Create Order Items (Bulk Insert)
    final List<Map<String, dynamic>> orderItemsData = items.map((item) {
      return {
        'order_id': orderId,
        'product_id': item.product.id,
        'quantity': item.quantity,
        'unit_price': item.product.salePrice ?? item.product.price,
        // We might want to store selected color/size in a metadata column later
        // For now, we assume standard items. 
        // Note: To support variants fully, we'd add 'metadata' jsonb column to order_items table.
      };
    }).toList();

    await _client.from('order_items').insert(orderItemsData);
  }
}
