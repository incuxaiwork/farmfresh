import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SnackBarType { success, error, info, warning }

void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.success,
  Duration duration = const Duration(seconds: 1),
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlayState = Overlay.of(context);
  
  Color bgColor = const Color(0xFF2E7D32);
  final IconData icon;

  switch (type) {
    case SnackBarType.success:
      bgColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline_rounded;
      break;
    case SnackBarType.error:
      bgColor = const Color(0xFFFF4D6D); // Nice soft pinkish-red matching app colors
      icon = Icons.error_outline_rounded;
      break;
    case SnackBarType.warning:
      bgColor = const Color(0xFFF3A05B); // Orange-accent matching app colors
      icon = Icons.warning_amber_rounded;
      break;
    case SnackBarType.info:
      bgColor = const Color(0xFF1976D2);
      icon = Icons.info_outline_rounded;
      break;
  }

  late OverlayEntry overlayEntry;
  
  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: 24, // Display at the top-right of the page
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: _ToastWidget(
            message: message,
            icon: icon,
            bgColor: bgColor,
            duration: duration,
            onDismiss: () {
              overlayEntry.remove();
            },
          ),
        ),
      );
    },
  );

  overlayState.insert(overlayEntry);
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color bgColor;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.icon,
    required this.bgColor,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0.0), // Slide in from the right edge
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    // Trigger smooth reverse slide-out animation 250ms before duration expires
    _timer = Timer(widget.duration - const Duration(milliseconds: 250), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
