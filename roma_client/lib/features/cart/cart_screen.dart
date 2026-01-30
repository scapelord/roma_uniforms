import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roma_shared/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roma_client/features/cart/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      appBar: AppBar(
        backgroundColor: RomaColors.pitLaneGrey,
        title: Text("PIT LANE (CART)", style: GoogleFonts.orbitron(letterSpacing: 1.5)),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: RomaColors.ferrariRed),
              onPressed: () => notifier.clearCart(),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("GRID IS EMPTY", style: GoogleFonts.orbitron(fontSize: 20, color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _buildCartCard(item, notifier);
              },
            ),
      
      // TOTAL SUMMARY
      bottomNavigationBar: cartItems.isEmpty ? null : Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: RomaColors.pitLaneGrey,
          border: Border(top: BorderSide(color: RomaColors.carbonFiber)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("TOTAL", style: TextStyle(color: Colors.grey)),
                  Text(
                    "KES ${notifier.grandTotal.toStringAsFixed(0)}",
                    style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: RomaColors.electricBlue),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: RomaColors.ferrariRed,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                },
                child: const Text("CHECKOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartCard(CartItem item, CartNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RomaColors.carbonFiber),
      ),
      child: Row(
        children: [
          // Image Thumbnail
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
              image: item.product.images.isNotEmpty
                  ? DecorationImage(image: NetworkImage(item.product.images.first), fit: BoxFit.cover)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  "${item.selectedSize ?? '-'} | ${item.selectedColor ?? '-'}", 
                  style: const TextStyle(color: Colors.white54, fontSize: 12)
                ),
                const SizedBox(height: 4),
                Text(
                  "KES ${item.product.salePrice ?? item.product.price}",
                  style: const TextStyle(color: RomaColors.electricBlue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Controls
          Row(
            children: [
              Text("x${item.quantity}", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16)),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => notifier.removeFromCart(item),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
