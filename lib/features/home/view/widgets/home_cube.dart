import 'dart:math' as math;

import 'package:dllni_user_app/features/home/data/models/fetch_user_offers_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube_transition/flutter_cube_transition.dart';

import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';

/// Kept as the alternative V7 presentation, not the default customer UI.
/// Enable via --dart-define=ALNADHA_AD_STYLE=cube.
/// The same real backend offers are used by this and the editorial carousel.
class HomeCube extends StatefulWidget {
  const HomeCube({super.key, required this.offers});
  final List<UserOfferItem> offers;

  @override
  State<HomeCube> createState() => _HomeCubeState();
}

class _HomeCubeState extends State<HomeCube> {
  static const _faces = [
    CubeFace.front,
    CubeFace.back,
    CubeFace.right,
    CubeFace.left,
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty) return const SizedBox.shrink();
    final padded = List<UserOfferItem>.generate(
      4,
      (index) => widget.offers[index % widget.offers.length],
    );
    final width = math.min(MediaQuery.sizeOf(context).width - 40, 380.0);
    return Semantics(
      label: 'العروض الإعلانية، اسحب لاستعراض الأوجه الأربعة',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: FlutterCubeTransition(
          width: width * .74,
          height: 192,
          secondsToSwipe: const Duration(seconds: 4),
          animationDuration: const Duration(milliseconds: 250),
          animationCurve: Curves.easeOutCubic,
          enableHapticFeedback: true,
          perspectiveStrength: .0015,
          showControls: false,
          borderVisible: false,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          textAlign: Alignment.topLeft,
          borderRadius: BorderRadius.circular(20),
          dragSensitivity: .006,
          dragThreshold: .6,
          faceTextStyle: const TextStyle(
            fontSize: 1,
            color: Colors.transparent,
          ),
          faces: {
            for (var i = 0; i < _faces.length; i++)
              _faces[i]: _faceForOffer(padded[i]),
          },
        ),
      ),
    );
  }

  CubeFaceData _faceForOffer(UserOfferItem offer) {
    final image = (offer.imageUrl ?? '').trim();
    final title = (offer.title ?? '').trim();
    final label = (offer.discountLabel ?? '').trim();
    final desc = (offer.description ?? '').trim();
    return CubeFaceData(
      color: SharedPlatformColors.primary,
      text: '',
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image.isNotEmpty)
            Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Image.asset(V7Artwork.cleaningPhoto, fit: BoxFit.cover),
            )
          else
            Image.asset(V7Artwork.cleaningPhoto, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xE6172554),
                  Color(0x96172554),
                  Color(0x18172554),
                ],
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty) ...[
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8DE4E8),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (title.isNotEmpty)
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        height: 1.35,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
