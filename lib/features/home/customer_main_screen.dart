import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/cart_provider.dart';
import 'home_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';

class CustomerMainScreen extends ConsumerStatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  ConsumerState<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends ConsumerState<CustomerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(cartProvider).itemCount;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF2F8F4),
            Color(0xFFE6F2EA),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: const Border(
              top: BorderSide(color: Color(0x0A000000), width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: const Color(0xFF647C72),
            selectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.storefront_outlined, size: 20),
                activeIcon: Icon(Icons.storefront, size: 20),
                label: 'Market',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: cartItemCount > 0,
                  label: Text('$cartItemCount'),
                  backgroundColor: const Color(0xFFE63946),
                  textColor: Colors.white,
                  child: const Icon(Icons.shopping_basket_outlined, size: 20),
                ),
                activeIcon: Badge(
                  isLabelVisible: cartItemCount > 0,
                  label: Text('$cartItemCount'),
                  backgroundColor: const Color(0xFFE63946),
                  textColor: Colors.white,
                  child: const Icon(Icons.shopping_basket, size: 20),
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined, size: 20),
                activeIcon: Icon(Icons.receipt_long, size: 20),
                label: 'Track',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 20),
                activeIcon: Icon(Icons.person, size: 20),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
