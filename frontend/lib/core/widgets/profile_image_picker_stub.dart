import 'package:flutter/material.dart';

class ProfileImagePickerService {
  static void pickImage(BuildContext context, void Function(String base64Image) onSelected) {
    _showMockAvatarPicker(context, onSelected);
  }

  static void openCamera(BuildContext context, void Function(String base64Image) onCaptured) {
    _showMockAvatarPicker(context, onCaptured);
  }

  static void _showMockAvatarPicker(BuildContext context, void Function(String base64Image) onSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Profile Picture'),
        content: const Text('On physical mobile devices, choose a demo profile avatar below to test the cropping and update features:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // A nice dummy base64 profile placeholder
              onSelected('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
            },
            child: const Text('Green Logo Avatar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
