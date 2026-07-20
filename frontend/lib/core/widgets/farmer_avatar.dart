import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class AvatarPreset {
  final String id;
  final IconData icon;
  final Color color;

  const AvatarPreset({
    required this.id,
    required this.icon,
    required this.color,
  });
}

class FarmerAvatarPresets {
  static const List<AvatarPreset> presets = [
    AvatarPreset(id: 'avatar_leaf_green', icon: Icons.eco, color: Color(0xFF4CAF50)),
    AvatarPreset(id: 'avatar_apple_red', icon: Icons.apple, color: Color(0xFFE53935)),
    AvatarPreset(id: 'avatar_spa_teal', icon: Icons.spa, color: Color(0xFF00897B)),
    AvatarPreset(id: 'avatar_tractor_blue', icon: Icons.agriculture, color: Color(0xFF1E88E5)),
    AvatarPreset(id: 'avatar_flower_pink', icon: Icons.local_florist, color: Color(0xFFD81B60)),
    AvatarPreset(id: 'avatar_droplet_blue', icon: Icons.water_drop, color: Color(0xFF039BE5)),
    AvatarPreset(id: 'avatar_grass_green', icon: Icons.grass, color: Color(0xFF7CB342)),
  ];

  static AvatarPreset? getById(String id) {
    try {
      return presets.firstWhere((preset) => preset.id == id);
    } catch (_) {
      return null;
    }
  }
}

class FarmerAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double radius;

  const FarmerAvatar({
    super.key,
    required this.avatarUrl,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl ?? '';

    if (url.isEmpty) {
      return _buildDefaultAvatar();
    }

    final preset = FarmerAvatarPresets.getById(url);
    if (preset != null) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: preset.color.withOpacity(0.15),
        ),
        child: Icon(
          preset.icon,
          color: preset.color,
          size: radius,
        ),
      );
    }

    String fullUrl = url;
    if (url.startsWith('/public/')) {
      final baseUrl = AppConstants.apiBaseUrl.replaceAll('/api', '');
      fullUrl = '$baseUrl$url';
    } else if (!url.startsWith('http')) {
      final baseUrl = AppConstants.apiBaseUrl.replaceAll('/api', '');
      fullUrl = '$baseUrl/$url';
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(fullUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEAF3E4),
      ),
      child: Icon(
        Icons.person,
        color: const Color(0xFF2E7D32),
        size: radius,
      ),
    );
  }
}
