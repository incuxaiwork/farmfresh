import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_image_picker_dialog.dart';

class ProfileImagePickerService {
  static void pickImage(BuildContext context, void Function(String base64Image) onSelected) {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((event) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((event) {
          final base64Image = reader.result as String;
          onSelected(base64Image);
        });
      }
    });
  }

  static void openCamera(BuildContext context, void Function(String base64Image) onCaptured) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WebCameraDialog(
        onCaptured: onCaptured,
      ),
    );
  }
}

class WebCameraDialog extends StatefulWidget {
  final Function(String base64Image) onCaptured;

  const WebCameraDialog({super.key, required this.onCaptured});

  @override
  State<WebCameraDialog> createState() => _WebCameraDialogState();
}

class _WebCameraDialogState extends State<WebCameraDialog> {
  html.VideoElement? _videoElement;
  html.MediaStream? _stream;
  String? _capturedImage;
  bool _isLoading = true;
  String _viewId = 'web-camera-view';

  @override
  void initState() {
    super.initState();
    _viewId = 'web-camera-view-${DateTime.now().millisecondsSinceEpoch}';
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    // Register platform view factory dynamically
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int id) => _videoElement!,
    );

    _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({'video': true});
      _stream = stream;
      if (_videoElement != null) {
        _videoElement!.srcObject = stream;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open camera: $e'), backgroundColor: Colors.red),
      );
      Navigator.pop(context);
    }
  }

  void _capture() {
    if (_videoElement == null) return;
    final width = _videoElement!.videoWidth;
    final height = _videoElement!.videoHeight;
    if (width == 0 || height == 0) return;

    final canvas = html.CanvasElement(width: width, height: height);
    final ctx = canvas.context2D;
    ctx.drawImage(_videoElement!, 0, 0);
    final dataUrl = canvas.toDataUrl('image/jpeg');

    setState(() {
      _capturedImage = dataUrl;
    });
  }

  void _retake() {
    setState(() {
      _capturedImage = null;
    });
  }

  void _save() {
    if (_capturedImage != null) {
      widget.onCaptured(_capturedImage!);
    }
    Navigator.pop(context);
  }

  void _stopCamera() {
    _stream?.getTracks().forEach((track) {
      track.stop();
    });
    _videoElement?.srcObject = null;
  }

  @override
  void dispose() {
    _stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _capturedImage == null ? 'Take Instant Photo' : 'Confirm Photo',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF23312B),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5EDE7), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _capturedImage == null
                    ? (_isLoading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                        : HtmlElementView(viewType: _viewId))
                    : Image.memory(
                        base64Decode(_capturedImage!.split(',')[1]),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 24),
            if (_capturedImage == null) ...[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _capture,
                icon: const Icon(Icons.camera, color: Colors.white),
                label: Text('Capture', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: _retake,
                    icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
                    label: Text('Retake', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text('Ok', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF647C72),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
