// Configures the application's routing using GoRouter
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product_model.dart';

// Import feature screens
import '../features/splash/splash_screen.dart';
import '../features/authentication/login_screen.dart';
import '../features/authentication/signup_screen.dart';
import '../features/home/customer_main_screen.dart';
import '../features/home/home_screen.dart';
import '../features/products/product_details_screen.dart';
import '../features/products/products_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/wishlist/wishlist_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/farmer/farmer_main_screen.dart';

import '../features/delivery/delivery_main_screen.dart';

// Defines all the routes for the application
final GoRouter appRouter = GoRouter(
  initialLocation: '/login', // Start directly at login for demonstration
  routes: [
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
    // Main Customer shell (Bottom Navigation)
    GoRoute(
      path: '/customer-main',
      name: 'customer-main',
      builder: (context, state) => const CustomerMainScreen(),
    ),
    // Main Farmer shell (Bottom Navigation)
    GoRoute(
      path: '/farmer-main',
      name: 'farmer-main',
      builder: (context, state) => const FarmerMainScreen(),
    ),
    // Main Delivery Partner shell
    GoRoute(
      path: '/delivery-main',
      name: 'delivery-main',
      builder: (context, state) => const DeliveryMainScreen(),
    ),
    // Sub-pages/Details
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/product-details',
      name: 'product-details',
      builder: (context, state) {
        final product = state.extra as ProductModel?;
        return ProductDetailsScreen(product: product);
      },
    ),
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return ProductsScreen(initialCategory: category);
      },
    ),
    GoRoute(
      path: '/cart',
      name: 'cart',
      builder: (context, state) => const CartScreen(),
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
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
