import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClOccasionTypeCardWidget extends StatelessWidget {
  const ClOccasionTypeCardWidget({
    required this.title,
    required this.imagePath,
    required this.onTap,
    super.key,
  });

  final String title;
  final String imagePath;
  final VoidCallback onTap;

  bool get _isNetworkImage {
    final uri = Uri.tryParse(imagePath);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Widget _buildImage(BuildContext context) {
    if (_isNetworkImage) {
      return AppImage.network(
        imagePath,
        width: context.width,
        height: 182,
        fit: BoxFit.cover,
        errorWidget: Container(
          color: const Color(0xFFF3F4F6),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_outlined,
            color: Color(0xFF9CA3AF),
            size: 36,
          ),
        ),
      );
    }

    return AppImage.asset(
      imagePath,
      width: context.width,
      height: 182,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 182,
          width: context.width,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(context),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppText.bodyMedium(
                              title,
                              fontWeight: FontWeight.w700,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
