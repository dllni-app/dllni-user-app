import 'dart:io';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ProfilePhotoSection extends StatelessWidget {
  const ProfilePhotoSection({
    super.key,
    required this.accentColor,
    required this.onPickGallery,
    required this.onPickCamera,
    this.localFile,
    this.networkImageUrl,
  });

  final Color accentColor;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final File? localFile;
  final String? networkImageUrl;

  ImageProvider? get _imageProvider {
    if (localFile != null) return FileImage(localFile!);
    if (networkImageUrl != null && networkImageUrl!.isNotEmpty) {
      return NetworkImage(networkImageUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: const Color(0xffE5E7EB),
          backgroundImage: _imageProvider,
          child: _imageProvider == null
              ? Icon(Icons.person, size: 48, color: Colors.grey.shade500)
              : null,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionChip(
              icon: Icons.image_outlined,
              label: 'اختيار من المعرض',
              onTap: onPickGallery,
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 24,
              child: VerticalDivider(color: Colors.grey.shade400, thickness: 1),
            ),
            const SizedBox(width: 8),
            _ActionChip(
              icon: Icons.camera_alt_outlined,
              label: 'التقاط صورة',
              onTap: onPickCamera,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xff1F2A5A)),
            const SizedBox(width: 6),
            AppText.bodySmall(
              label,
              color: const Color(0xff1F2A5A),
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
