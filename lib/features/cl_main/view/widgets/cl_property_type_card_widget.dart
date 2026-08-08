import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../data/cl_main_route_args.dart';

class ClPropertyTypeCardWidget extends StatelessWidget {
  const ClPropertyTypeCardWidget({
    required this.title,
    required this.icon,
    required this.args,
    super.key,
  });

  final String title;
  final String icon;
  final ClMainHomeDescriptionArgs args;

  bool get _isNetworkImage {
    final uri = Uri.tryParse(icon);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Widget _buildImage(BuildContext context) {
    if (_isNetworkImage) {
      return AppImage.network(
        icon,
        width: context.width,
        height: 200,
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
      icon,
      width: context.width,
      height: 200,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.pushRoute('/clmainhomedescription', arguments: args);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: context.width,
          height: 200,
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText.bodyMedium(
                            title,
                            fontWeight: FontWeight.w700,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
