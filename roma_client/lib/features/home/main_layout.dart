import 'package:flutter/material.dart';
import 'package:roma_shared/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
// Import your screens (we will create placeholders for now)
import 'catalogue_screen.dart'; 
import 'package:roma_client/features/cart/cart_screen.dart'; 
import 'package:roma_client/features/orders/orders_screen.dart';

import 'package:roma_client/features/profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // The "Gearbox" - Pages mapped to the tray
  final List<Widget> _pages = [
    const CatalogueScreen(),      // 0: Catalogue
    const Center(child: Text("Categories Page", style: TextStyle(color: Colors.white))), // 1: Categories
    const CartScreen(),       // 2: Cart
    const OrdersScreen(),     // 3: Orders
    const ProfileScreen(),    // 4: Account/Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      body: _pages[_currentIndex],
      
      // THE QUICK TRAY
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: RomaColors.pitLaneGrey,
          border: Border(top: BorderSide(color: RomaColors.carbonFiber, width: 2)),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          indicatorColor: RomaColors.ferrariRed.withOpacity(0.2),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view, color: Colors.white54),
              selectedIcon: Icon(Icons.grid_view, color: RomaColors.ferrariRed),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Icon(Icons.category, color: Colors.white54),
              selectedIcon: Icon(Icons.category, color: RomaColors.ferrariRed),
              label: 'Cats',
            ),
            NavigationDestination(
              icon: Badge(label: Text('2'), child: Icon(Icons.shopping_bag_outlined, color: Colors.white54)),
              selectedIcon: Icon(Icons.shopping_bag, color: RomaColors.ferrariRed),
              label: 'Cart',
            ),
             NavigationDestination(
              icon: Icon(Icons.local_shipping_outlined, color: Colors.white54),
              selectedIcon: Icon(Icons.local_shipping, color: RomaColors.ferrariRed),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.white54),
              selectedIcon: Icon(Icons.person, color: RomaColors.ferrariRed),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
