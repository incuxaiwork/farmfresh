import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';

// Import feature screens
import '../features/splash/splash_screen.dart';
import '../features/authentication/login_screen.dart';
import '../features/authentication/signup_screen.dart';
import '../features/home/customer_main_screen.dart';
import '../features/products/product_details_screen.dart';
import '../features/products/products_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/wishlist/wishlist_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/orders/order_tracking_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/change_password_screen.dart';
import '../features/profile/privacy_policy_screen.dart';
import '../features/profile/terms_conditions_screen.dart';
import '../features/profile/addresses_screen.dart';
import '../features/profile/add_edit_address_screen.dart';
import '../models/address_model.dart';
import '../features/farmer/farmer_main_screen.dart';
import '../features/farmer/farmer_add_edit_product_screen.dart';
import '../features/farmer/farmer_edit_profile_screen.dart';
import '../features/farmer/farmer_inventory_screen.dart';
import '../features/farmer/farmer_withdrawal_screen.dart';
import '../features/farmer/farmer_notifications_screen.dart';
import '../features/farmer/farmer_order_detail_screen.dart';
import '../features/delivery/delivery_main_screen.dart';
import '../features/delivery/delivery_detail_screen.dart';
import '../features/delivery/delivery_navigation_screen.dart';
import '../features/delivery/delivery_earnings_screen.dart';
import '../features/delivery/delivery_history_screen.dart';
import '../features/delivery/delivery_notifications_screen.dart';
import '../models/delivery_model.dart';
import '../features/delivery/delivery_profile_screen.dart';
import '../features/admin/admin_main_screen.dart';
import '../features/support/customer_query_screen.dart';
import '../features/home/customer_notifications_screen.dart';

import 'package:flutter/foundation.dart';

/// Riverpod provider for the GoRouter instance.
/// Listens to authProvider changes for reactive routing and redirection.
final appRouter = Provider<GoRouter>((ref) {
  // Create a listenable to trigger GoRouter redirects when auth state changes
  final authStateListenable = ValueNotifier<bool>(false);
  
  // Listen to auth state changes and notify the router
  ref.listen<AuthState>(authProvider, (previous, next) {
    authStateListenable.value = !authStateListenable.value;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authStateListenable,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/customer-main',
        name: 'customer-main',
        builder: (context, state) => const CustomerMainScreen(),
      ),
      GoRoute(
        path: '/farmer-main',
        name: 'farmer-main',
        builder: (context, state) => const FarmerMainScreen(),
      ),
      GoRoute(
        path: '/delivery-main',
        name: 'delivery-main',
        builder: (context, state) => const DeliveryMainScreen(),
      ),
      GoRoute(
        path: '/admin-main',
        name: 'admin-main',
        builder: (context, state) => const AdminMainScreen(),
      ),
      GoRoute(
        path: '/delivery-detail',
        name: 'delivery-detail',
        builder: (context, state) {
          final deliveryId = state.extra as String;
          return DeliveryDetailScreen(deliveryId: deliveryId);
        },
      ),
      GoRoute(
        path: '/delivery-navigation',
        name: 'delivery-navigation',
        builder: (context, state) {
          final delivery = state.extra as DeliveryOrder;
          return DeliveryNavigationScreen(delivery: delivery);
        },
      ),
      GoRoute(
        path: '/product-details',
        builder: (context, state) {
          final product = state.extra as ProductModel?;
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: '/product-details/:id',
        name: 'product-details',
        builder: (context, state) {
          final product = state.extra as ProductModel?;
          final id = state.pathParameters['id'];
          return ProductDetailsScreen(product: product, productId: id);
        },
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          final search = state.uri.queryParameters['search'];
          return ProductsScreen(initialCategory: category, initialSearch: search);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const CustomerNotificationsScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        name: 'wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/order-detail/:id',
        name: 'order-detail',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/order-tracking/:id',
        name: 'order-tracking',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/support',
        name: 'support',
        builder: (context, state) {
          final orderId = state.extra as String?;
          return CustomerQueryScreen(initialOrderId: orderId);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms-conditions',
        name: 'terms-conditions',
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/addresses',
        name: 'addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/farmer-add-product',
        name: 'farmer-add-product',
        builder: (context, state) {
          final product = state.extra as ProductModel?;
          return FarmerAddEditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: '/farmer-edit-profile',
        name: 'farmer-edit-profile',
        builder: (context, state) => const FarmerEditProfileScreen(),
      ),
      GoRoute(
        path: '/farmer-inventory',
        name: 'farmer-inventory',
        builder: (context, state) => const FarmerInventoryScreen(),
      ),
      GoRoute(
        path: '/farmer-withdrawal',
        name: 'farmer-withdrawal',
        builder: (context, state) => const FarmerWithdrawalScreen(),
      ),
      GoRoute(
        path: '/farmer-notifications',
        name: 'farmer-notifications',
        builder: (context, state) => const FarmerNotificationsScreen(),
      ),
      GoRoute(
        path: '/farmer-order-detail/:id',
        name: 'farmer-order-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FarmerOrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/delivery-earnings',
        name: 'delivery-earnings',
        builder: (context, state) => const DeliveryEarningsScreen(),
      ),
      GoRoute(
        path: '/delivery-history',
        name: 'delivery-history',
        builder: (context, state) => const DeliveryHistoryScreen(),
      ),
      GoRoute(
        path: '/delivery-notifications',
        name: 'delivery-notifications',
        builder: (context, state) => const DeliveryNotificationsScreen(),
      ),
      GoRoute(
        path: '/delivery-profile',
        name: 'delivery-profile',
        builder: (context, state) => const DeliveryProfileScreen(),
      ),
      GoRoute(
        path: '/add-address',
        name: 'add-address',
        builder: (context, state) => const AddEditAddressScreen(),
      ),
      GoRoute(
        path: '/add-edit-address',
        name: 'edit-address',
        builder: (context, state) {
          final address = state.extra as AddressModel?;
          return AddEditAddressScreen(address: address);
        },
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.user != null;
      final location = state.matchedLocation;

      print('[ROUTER] Redirect check: isLoggedIn=$isLoggedIn, isLoading=$isLoading, location=$location, role=${authState.user?.role}');

      // Handle loading states
      if (isLoading) {
        if (location == '/splash') return null;
        return null;
      }

      final isLoggingIn = location == '/login' || location == '/signup' || location == '/splash';

      if (!isLoggedIn) {
        // User not logged in, redirect to login if not already there
        if (!isLoggingIn) {
          return '/login';
        }
        return null;
      }

      // User is logged in, handle initial login redirects and strict role guards
      final role = authState.user!.role.toUpperCase();

      if (isLoggingIn) {
        if (role == 'FARMER') return '/farmer-main';
        if (role == 'DELIVERY_PARTNER') return '/delivery-main';
        if (role == 'ADMIN') return '/admin-main';
        return '/customer-main';
      }

      // STRICT ROLE ISOLATION GUARDS
      final isCustomerRoute = location.startsWith('/cart') || location.startsWith('/wishlist') || 
                              location.startsWith('/orders') || location.startsWith('/order-detail') || 
                              location.startsWith('/order-tracking') || location.startsWith('/products') || 
                              location.startsWith('/product-details') || location.startsWith('/addresses') || 
                              location.startsWith('/add-address') || location == '/customer-main';
                              
      final isFarmerRoute = location.startsWith('/farmer-');
      final isDeliveryRoute = location.startsWith('/delivery-');
      final isAdminRoute = location.startsWith('/admin-');

      if (role == 'CUSTOMER') {
        if (isFarmerRoute || isDeliveryRoute || isAdminRoute) return '/customer-main';
      } else if (role == 'FARMER') {
        if (isDeliveryRoute || isAdminRoute || isCustomerRoute) return '/farmer-main';
      } else if (role == 'DELIVERY_PARTNER') {
        if (isFarmerRoute || isAdminRoute || isCustomerRoute) return '/delivery-main';
      } else if (role == 'ADMIN') {
        if (isFarmerRoute || isDeliveryRoute || isCustomerRoute || location == '/profile' || location == '/change-password') return '/admin-main';
      }

      return null;
    },
  );
});
