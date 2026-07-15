import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileImagePickerDialog extends StatefulWidget {
  final String userId;
  final Function(String base64Image, double scale, double dx, double dy) onImageSelected;

  const ProfileImagePickerDialog({
    super.key,
    required this.userId,
    required this.onImageSelected,
  });

  static void show(
    BuildContext context, {
    required String userId,
    required Function(String base64Image, double scale, double dx, double dy) onImageSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ProfileImagePickerDialog(
        userId: userId,
        onImageSelected: onImageSelected,
      ),
    );
  }

  @override
  State<ProfileImagePickerDialog> createState() => _ProfileImagePickerDialogState();
}

class _ProfileImagePickerDialogState extends State<ProfileImagePickerDialog> {
  void _pickImage({bool useFiles = false}) {
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
          Navigator.pop(context); // Close selection sheet
          _showAdjustmentDialog(base64Image);
        });
      }
    });
  }

  void _openCamera() {
    Navigator.pop(context); // Close selection sheet
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WebCameraDialog(
        onCaptured: (base64Image) {
          _showAdjustmentDialog(base64Image);
        },
      ),
    );
  }

  void _showAdjustmentDialog(String base64Image) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ImageAdjustmentDialog(
        base64Image: base64Image,
        onSave: (scale, dx, dy) {
          widget.onImageSelected(base64Image, scale, dx, dy);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Profile Picture',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF23312B),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take Photo',
                color: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF2E7D32),
                onTap: _openCamera,
              ),
              _buildOption(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                color: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF1E88E5),
                onTap: () => _pickImage(),
              ),
              _buildOption(
                icon: Icons.folder_open_outlined,
                label: 'Files',
                color: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFFB8C00),
                onTap: () => _pickImage(useFiles: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFECECEC)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 24,
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF647C72),
              ),
            ),
          ],
        ),
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
              // Live camera capture shutter button
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
              // Confirm captured image with retake / ok options
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

class ImageAdjustmentDialog extends StatefulWidget {
  final String base64Image;
  final Function(double scale, double dx, double dy) onSave;

  const ImageAdjustmentDialog({
    super.key,
    required this.base64Image,
    required this.onSave,
  });

  @override
  State<ImageAdjustmentDialog> createState() => _ImageAdjustmentDialogState();
}

class _ImageAdjustmentDialogState extends State<ImageAdjustmentDialog> {
  double _scale = 1.0;
  double _dx = 0.0;
  double _dy = 0.0;

  @override
  Widget build(BuildContext context) {
    final imageBytes = base64Decode(widget.base64Image.split(',')[1]);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Adjust Photo',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF23312B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Drag to position, slider to zoom',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF647C72),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _dx += details.delta.dx;
                  _dy += details.delta.dy;
                });
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE8F5E9), width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F2E5C45),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(_dx, _dy),
                          child: Transform.scale(
                            scale: _scale,
                            child: Image.memory(
                              imageBytes,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.zoom_out, color: Color(0xFF647C72), size: 16),
                Expanded(
                  child: Slider(
                    value: _scale,
                    min: 1.0,
                    max: 3.0,
                    activeColor: const Color(0xFF2E7D32),
                    inactiveColor: const Color(0xFFE5EDE7),
                    onChanged: (val) {
                      setState(() {
                        _scale = val;
                      });
                    },
                  ),
                ),
                const Icon(Icons.zoom_in, color: Color(0xFF647C72), size: 16),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(_scale, _dx, _dy);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
