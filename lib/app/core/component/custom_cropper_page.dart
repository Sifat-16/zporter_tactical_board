import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class CustomCropperPage extends StatefulWidget {
  final Widget cropper;
  final void Function() initCropper;
  final Future<String?> Function() crop;
  final void Function(RotationAngle) rotate;

  const CustomCropperPage({
    super.key,
    required this.cropper,
    required this.initCropper,
    required this.crop,
    required this.rotate,
  });

  @override
  State<CustomCropperPage> createState() => _CustomCropperPageState();
}

class _CustomCropperPageState extends State<CustomCropperPage> {
  @override
  void initState() {
    super.initState();
    widget.initCropper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1F24), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1F24),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Crop Image',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFFFFC107)),
            iconSize: 28,
            onPressed: () async {
              final result = await widget.crop();
              if (context.mounted) {
                Navigator.of(context).pop(result);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Cropper area
          Expanded(
            child: Container(
              color: const Color(0xFF1E1F24),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.cropper,
                ),
              ),
            ),
          ),
          // Bottom toolbar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2B30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildToolButton(
                    icon: Icons.rotate_left,
                    label: 'Rotate Left',
                    onPressed: () =>
                        widget.rotate(RotationAngle.counterClockwise90),
                  ),
                  _buildToolButton(
                    icon: Icons.rotate_right,
                    label: 'Rotate Right',
                    onPressed: () => widget.rotate(RotationAngle.clockwise90),
                  ),
                  _buildToolButton(
                    icon: Icons.flip,
                    label: 'Flip',
                    onPressed: () => widget.rotate(RotationAngle.clockwise180),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFFFFC107),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
