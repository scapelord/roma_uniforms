import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roma_shared/models/product_model.dart';

// 1. Update CartItem to have toJson/fromJson
class CartItem {
  final Product product;
  final int quantity;
  final String? selectedColor;
  final String? selectedSize;

  CartItem({required this.product, this.quantity = 1, this.selectedColor, this.selectedSize});

  Map<String, dynamic> toJson() => {
    'product': { // Minimal product data needed to reconstruct or full json
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'sale_price': product.salePrice,
      'images': product.images,
      'description': product.description,
      'category': product.category,
      'stock_level': product.stockLevel,
      'status': product.status,
    },
    'quantity': quantity,
    'selectedColor': selectedColor,
    'selectedSize': selectedSize,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      selectedColor: json['selectedColor'],
      selectedSize: json['selectedSize'],
    );
  }
  
  double get totalPrice => (product.salePrice ?? product.price) * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _loadCart(); // Load immediately on startup
  }

  // SAVE TO DISK
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString('roma_cart', encoded);
  }

  // LOAD FROM DISK
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString('roma_cart');
    if (encoded != null) {
      final List<dynamic> list = jsonDecode(encoded);
      state = list.map((e) => CartItem.fromJson(e)).toList();
    }
  }

  void addToCart(Product product, {String? color, String? size}) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id && item.selectedColor == color && item.selectedSize == size);
    
    if (existingIndex >= 0) {
      final oldItem = state[existingIndex];
      state = [...state.sublist(0, existingIndex), CartItem(product: product, quantity: oldItem.quantity + 1, selectedColor: color, selectedSize: size), ...state.sublist(existingIndex + 1)];
    } else {
      state = [...state, CartItem(product: product, selectedColor: color, selectedSize: size)];
    }
    _saveCart(); // Auto Save
  }

  void removeFromCart(CartItem item) {
    state = state.where((element) => element != item).toList();
    _saveCart(); // Auto Save
  }
  
  void clearCart() {
    state = [];
    _saveCart(); // Auto Save
  }
  
  double get grandTotal => state.fold(0, (sum, item) => sum + item.totalPrice);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
