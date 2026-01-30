import 'package:flutter/material.dart';
import 'package:roma_shared/theme/app_colors.dart';
import 'package:roma_admin/services/admin_supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _service = AdminSupabaseService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final data = await _service.fetchAllOrders();
    setState(() {
      _orders = data;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(String id, String status) async {
    await _service.updateOrderStatus(id, status);
    _loadOrders(); // Refresh to see change
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      appBar: AppBar(
        title: Text("DISPATCH CENTER", style: GoogleFonts.orbitron()),
        backgroundColor: RomaColors.pitLaneGrey,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                return _buildAdminOrderCard(_orders[index]);
              },
            ),
    );
  }

  Widget _buildAdminOrderCard(Map<String, dynamic> order) {
    final user = order['profiles'] ?? {'full_name': 'Unknown', 'phone_number': 'N/A'};
    final status = order['status'];
    final items = order['order_items'] as List;

    return Card(
      color: RomaColors.pitLaneGrey,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(user['full_name'] ?? 'Client', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("KES ${order['total_amount']}", style: const TextStyle(color: RomaColors.ferrariRed, fontWeight: FontWeight.bold)),
              ],
            ),
            Text(user['phone_number'] ?? '', style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 8),
            
            // Location
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: RomaColors.electricBlue),
                const SizedBox(width: 4),
                Expanded(child: Text(order['delivery_address'], style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const Divider(color: Colors.white24),

            // Items Summary
            Text("${items.length} Items: ${items.map((i) => i['products']['name']).join(', ')}", 
                style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            
            const SizedBox(height: 12),

            // Action Buttons (Status Changer)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("STATUS: ${status.toString().toUpperCase()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                _buildStatusDropdown(order['id'], status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(String orderId, String currentStatus) {
    return DropdownButton<String>(
      value: currentStatus,
      dropdownColor: RomaColors.asphaltBlack,
      style: const TextStyle(color: RomaColors.electricBlue),
      underline: Container(), // Remove underline
      items: ['pending', 'processing', 'in_transit', 'delivered', 'cancelled']
          .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
      onChanged: (val) {
        if (val != null) _updateStatus(orderId, val);
      },
    );
  }
}
