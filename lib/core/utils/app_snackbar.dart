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
  final Color bgColor = const Color(0xFF2E7D32);
  final IconData icon;

  switch (type) {
    case SnackBarType.success:
      icon = Icons.check_circle_outline_rounded;
      break;
    case SnackBarType.error:
      icon = Icons.error_outline_rounded;
      break;
    case SnackBarType.warning:
      icon = Icons.warning_amber_rounded;
      break;
    case SnackBarType.info:
      icon = Icons.info_outline_rounded;
      break;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
}
