import 'package:flutter/material.dart';
import 'package:roma_shared/theme/app_colors.dart';
import 'package:roma_shared/models/product_model.dart';
import 'package:roma_admin/services/admin_supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roma_admin/features/orders/admin_orders_screen.dart';
import 'manage_product_screen.dart'; // We will build this next

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _service = AdminSupabaseService();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _service.fetchAllProducts();
    setState(() {
      _products = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      appBar: AppBar(
        backgroundColor: RomaColors.pitLaneGrey,
        title: Text("RACE CONTROL", style: GoogleFonts.orbitron(letterSpacing: 2, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_shipping, color: RomaColors.electricBlue),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: RomaColors.electricBlue),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: RomaColors.ferrariRed,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("NEW ITEM", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        onPressed: () => _navigateToEdit(null), // Null means "Create New"
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: RomaColors.ferrariRed))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildAdminCard(product);
              },
            ),
    );
  }

  Widget _buildAdminCard(Product product) {
    return Card(
      color: RomaColors.pitLaneGrey,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50, 
          height: 50,
          color: Colors.black,
          child: product.images.isNotEmpty 
            ? Image.network(product.images.first, fit: BoxFit.cover)
            : const Icon(Icons.image_not_supported, color: Colors.white24),
        ),
        title: Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(
          "Stock: ${product.stockLevel} | Price: ${product.price}",
          style: TextStyle(color: product.stockLevel < 10 ? RomaColors.ferrariRed : Colors.white54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // EDIT BUTTON
            IconButton(
              icon: const Icon(Icons.edit, color: RomaColors.electricBlue),
              onPressed: () => _navigateToEdit(product),
            ),
            // DELETE BUTTON
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(product),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(Product? product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ManageProductScreen(product: product)),
    );
    _loadData(); // Refresh list when we come back
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: RomaColors.pitLaneGrey,
        title: const Text("Retire this Part?", style: TextStyle(color: Colors.white)),
        content: Text("Delete '${product.name}' permanently?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(child: const Text("CANCEL"), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text("DELETE", style: TextStyle(color: RomaColors.ferrariRed)),
            onPressed: () async {
              Navigator.pop(context);
              await _service.deleteProduct(product.id);
              _loadData();
            },
          ),
        ],
      ),
    );
  }
}
