import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // We need this for state
import 'package:roma_shared/theme/app_colors.dart';
import 'package:roma_shared/models/product_model.dart';
import 'package:roma_client/features/shop/product_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  final _client = Supabase.instance.client;
  
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  
  // Search State
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Daily Uniform', 'Tops', 'Bottoms', 'Sportswear', 'Outerwear', 'Footwear', 'Accessories'];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await _client.from('products').select().order('created_at', ascending: false);
    final data = (response as List).map((json) => Product.fromJson(json)).toList();
    
    if (mounted) {
      setState(() {
        _allProducts = data;
        _filteredProducts = data; // Initially, show all
        _isLoading = false;
      });
    }
  }

  void _runFilter() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final matchesSearch = p.name.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      appBar: AppBar(
        backgroundColor: RomaColors.pitLaneGrey,
        title: Text("CATALOGUE", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _runFilter(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search gear (e.g., 'Sweater')",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: RomaColors.electricBlue),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // CATEGORY CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = val ? cat : 'All';
                        _runFilter();
                      });
                    },
                    backgroundColor: RomaColors.pitLaneGrey,
                    selectedColor: RomaColors.ferrariRed,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                    checkmarkColor: Colors.white,
                    side: BorderSide(color: isSelected ? RomaColors.ferrariRed : Colors.white24),
                  ),
                );
              }).toList(),
            ),
          ),

          // GRID
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: RomaColors.ferrariRed))
                : _filteredProducts.isEmpty
                    ? Center(child: Text("NO GEAR FOUND", style: GoogleFonts.orbitron(color: Colors.grey)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          // USE EXISTING ProductCard LOGIC
                          return _ProductCard(product: _filteredProducts[index]); 
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// Minimal Product Card (Integrated)
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: RomaColors.pitLaneGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: RomaColors.carbonFiber),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  image: product.images.isNotEmpty
                      ? DecorationImage(image: NetworkImage(product.images[0]), fit: BoxFit.cover)
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("KES ${product.price}", style: const TextStyle(color: RomaColors.ferrariRed, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
