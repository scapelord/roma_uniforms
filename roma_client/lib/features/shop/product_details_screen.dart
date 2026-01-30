import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roma_shared/theme/app_colors.dart';
import 'package:roma_shared/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roma_client/features/cart/cart_provider.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  String? _selectedSize;
  String? _selectedColor;

  // Hardcoded options for now (We can move this to DB later)
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _colors = ['Navy', 'Maroon', 'Green', 'Red', 'Black', 'Grey', 'White'];

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isGeneric = p.name.contains("Generic"); // Simple check logic

    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      body: CustomScrollView(
        slivers: [
          // 1. App Bar Image Header
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: RomaColors.asphaltBlack,
            flexibleSpace: FlexibleSpaceBar(
              background: p.images.isNotEmpty
                  ? Image.network(p.images.first, fit: BoxFit.cover)
                  : Container(color: Colors.grey[800], child: const Icon(Icons.image, size: 50)),
            ),
          ),

          // 2. Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "KES ${p.salePrice ?? p.price}",
                        style: GoogleFonts.orbitron(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: RomaColors.ferrariRed,
                        ),
                      ),
                      if (p.stockLevel < 20)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: RomaColors.safetyCarYellow,
                              borderRadius: BorderRadius.circular(4)),
                          child: Text("LOW STOCK: ${p.stockLevel}",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(p.name, style: GoogleFonts.roboto(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 24),

                  // SELECTORS
                  _buildSelectorTitle("SIZE"),
                  Wrap(
                    spacing: 8,
                    children: _sizes.map((s) => _buildChoiceChip(s, _selectedSize == s, (val) {
                      setState(() => _selectedSize = val ? s : null);
                    })).toList(),
                  ),
                  
                  const SizedBox(height: 24),

                  // Color Selector (Only show if Generic or needed)
                  if (isGeneric) ...[
                    _buildSelectorTitle("COLOR"),
                    Wrap(
                      spacing: 8,
                      children: _colors.map((c) => _buildChoiceChip(c, _selectedColor == c, (val) {
                        setState(() => _selectedColor = val ? c : null);
                      })).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  _buildSelectorTitle("SPECS"),
                  Text(p.description, style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 16)),
                  
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      
      // 3. Floating Add to Cart Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: RomaColors.pitLaneGrey,
          border: Border(top: BorderSide(color: RomaColors.carbonFiber)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RomaColors.electricBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              if (_selectedSize == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a Size")));
                return;
              }
              if (isGeneric && _selectedColor == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a Color")));
                return;
              }

              // ADD TO CART
              ref.read(cartProvider.notifier).addToCart(
                p, 
                size: _selectedSize, 
                color: isGeneric ? _selectedColor : "Standard"
              );

              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("${p.name} added to grid"),
                backgroundColor: RomaColors.ferrariRed,
              ));
              Navigator.pop(context);
            },
            child: Text("ADD TO PIT LANE (CART)", 
              style: GoogleFonts.orbitron(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: RomaColors.ferrariRed,
      backgroundColor: RomaColors.pitLaneGrey,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }
}
