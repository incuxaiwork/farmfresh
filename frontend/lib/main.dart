import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Global error boundary to surface silent rendering crashes ──
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('┌── FLUTTER ERROR ──');
    debugPrint('│ ${details.exceptionAsString()}');
    debugPrint('│ ${details.stack}');
    debugPrint('└───────────────────');
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('┌── PLATFORM ERROR ──');
    debugPrint('│ $error');
    debugPrint('│ $stack');
    debugPrint('└────────────────────');
    return true;
  };

  runApp(
    const ProviderScope(
      child: EcommerceApp(),
    ),
  );
}
