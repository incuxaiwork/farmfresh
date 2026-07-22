import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/cart_provider.dart';
import 'home_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/theme/app_theme.dart';

/// Provider to control the active tab in CustomerMainScreen from anywhere in the app.
final mainTabProvider = StateProvider<int>((ref) => 0);

class CustomerMainScreen extends ConsumerStatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  ConsumerState<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends ConsumerState<CustomerMainScreen> {
  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(cartProvider).itemCount;
    final selectedIndex = ref.watch(mainTabProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.getBackgroundGradient(context),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color?.withOpacity(0.85) ?? Colors.white.withOpacity(0.85),
            border: Border(
              top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.1), width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              ref.read(mainTabProvider.notifier).state = index;
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
