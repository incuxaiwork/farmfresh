import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ProductImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
  });

  String get _fullImageUrl {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://') || imageUrl.startsWith('blob:') || imageUrl.startsWith('data:')) {
      return imageUrl;
    }
    // Handle relative path (e.g. from local backend uploads)
    // Assuming AppConstants.apiBaseUrl is something like http://localhost:3000/api/v1
    // We want to extract just the host part.
    final uri = Uri.parse(AppConstants.apiBaseUrl);
    final baseUrl = '${uri.scheme}://${uri.host}:${uri.port}';
    
    if (imageUrl.startsWith('/')) {
      return '$baseUrl$imageUrl';
    }
    return '$baseUrl/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        _fullImageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F4),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: Icon(Icons.spa, color: Color(0xFF2E7D32), size: 30),
      ),
    );
  }
}
