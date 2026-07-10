// This is the main entry point of the Flutter application.
// It initializes core services (like Supabase) before running the UI.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecommerce_app/core/constants/app_constants.dart';
import 'app.dart';

void main() async {
  // Ensure that Flutter engine bindings are fully initialized before calling async code.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Supabase backend using credentials securely stored in AppConstants.
  try {
    if (AppConstants.supabaseUrl != 'https://YOUR_PROJECT_ID.supabase.co') {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    }
  } catch (e) {
    debugPrint('Supabase initialization failed, running in local-only fallback mode: $e');
  }

  // Run the app wrapped with ProviderScope.
  // This is required for flutter_riverpod to manage global state.
  runApp(
    const ProviderScope(
      child: EcommerceApp(),
    ),
  );
}
