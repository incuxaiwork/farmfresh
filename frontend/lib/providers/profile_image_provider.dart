import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileImageState {
  final String image;
  final double scale;
  final double dx;
  final double dy;

  ProfileImageState({
    required this.image,
    this.scale = 1.0,
    this.dx = 0.0,
    this.dy = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'image': image,
        'scale': scale,
        'dx': dx,
        'dy': dy,
      };

  factory ProfileImageState.fromJson(Map<String, dynamic> json) {
    return ProfileImageState(
      image: json['image'] as String,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      dx: (json['dx'] as num?)?.toDouble() ?? 0.0,
      dy: (json['dy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

final profileImageProvider = StateNotifierProvider.family<ProfileImageNotifier, ProfileImageState?, String>((ref, userId) {
  return ProfileImageNotifier(userId);
});

class ProfileImageNotifier extends StateNotifier<ProfileImageState?> {
  final String userId;
  final _secureStorage = const FlutterSecureStorage();

  ProfileImageNotifier(this.userId) : super(null) {
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final stored = await _secureStorage.read(key: 'profile_image_state_$userId');
      if (stored != null) {
        final decoded = jsonDecode(stored) as Map<String, dynamic>;
        state = ProfileImageState.fromJson(decoded);
        return;
      }
    } catch (_) {}

    try {
      final legacy = await _secureStorage.read(key: 'profile_image_$userId');
      if (legacy != null) {
        state = ProfileImageState(image: legacy);
        return;
      }
    } catch (_) {}
  }

  Future<void> updateProfileImage(String base64Image, {double scale = 1.0, double dx = 0.0, double dy = 0.0}) async {
    final newState = ProfileImageState(image: base64Image, scale: scale, dx: dx, dy: dy);
    state = newState;
    final jsonStr = jsonEncode(newState.toJson());
    try {
      await _secureStorage.write(key: 'profile_image_state_$userId', value: jsonStr);
    } catch (_) {}
  }

  Future<void> deleteProfileImage() async {
    state = null;
    try {
      await _secureStorage.delete(key: 'profile_image_state_$userId');
      await _secureStorage.delete(key: 'profile_image_$userId');
    } catch (_) {}
  }
}
