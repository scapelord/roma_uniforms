import 'package:flutter/material.dart';
import 'package:roma_shared/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roma_client/services/order_history_service.dart';
import 'package:intl/intl.dart'; 

import 'package:roma_client/services/pdf_invoice_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _service = OrderHistoryService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      appBar: AppBar(
        title: Text("MY GARAGE (ORDERS)", style: GoogleFonts.orbitron()),
        backgroundColor: RomaColors.pitLaneGrey,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _service.fetchMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: RomaColors.ferrariRed));
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("NO RECENT ACTIVITY", style: GoogleFonts.orbitron(color: Colors.grey)));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'].toString().toUpperCase();
    final total = order['total_amount'];
    final date = DateTime.parse(order['created_at']);
    final items = order['order_items'] as List;

    Color statusColor = Colors.grey;
    if (status == 'PENDING') statusColor = RomaColors.safetyCarYellow;
    if (status == 'IN_TRANSIT') statusColor = RomaColors.electricBlue;
    if (status == 'DELIVERED') statusColor = Colors.green;
    if (status == 'CANCELLED') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: RomaColors.pitLaneGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: ExpansionTile(
        title: Text("ORDER #${order['id'].toString().substring(0, 8)}", 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('MMM dd, yyyy').format(date), 
            style: const TextStyle(color: Colors.white54)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.print, color: Colors.white, size: 20),
              onPressed: () => PdfInvoiceService().printInvoice(order),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.white24),
                ...items.map((item) {
                  final product = item['products'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${item['quantity']}x ${product['name']}", style: const TextStyle(color: Colors.white70)),
                        Text("KES ${item['unit_price']}", style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("TOTAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("KES $total", style: TextStyle(color: RomaColors.ferrariRed, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
