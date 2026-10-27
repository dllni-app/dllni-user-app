import 'dart:math' as math;

import 'package:dllni_user_app/features/home/data/models/fetch_user_offers_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube_transition/flutter_cube_transition.dart';

import '../../../../core/themes/shared_platform_colors.dart';

/// Advertising cube with a reserved viewport for its projected faces.
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
    final serviceFaces = <UserOfferItem>[
      UserOfferItem(
        title: 'التنظيف المنزلي',
        description: 'بيت مرتّب ووقت أكثر إلك',
      ),
      UserOfferItem(title: 'المطاعم', description: 'أكلك المفضل لباب البيت'),
      UserOfferItem(title: 'التسوّق', description: 'كل احتياجاتك بمكان واحد'),
      UserOfferItem(title: 'التوصيل', description: 'مشاويرك علينا'),
    ];
    // A single backend campaign must not appear to be a frozen cube by
    // repeating the same artwork on all four faces. Fill unused faces with
    // honest service discovery content, never with invented promotions.
    final padded = <UserOfferItem>[
      ...widget.offers.take(4),
      ...serviceFaces,
    ].take(4).toList(growable: false);
    return Semantics(
      label: 'تعرّف على خدمات ع الندهة، اسحب المكعب لاستعراض الخدمات',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Leave room for the perspective projection throughout rotation.
            final side = math.min(constraints.maxWidth / 1.42, 260.0);
            return Center(
              child: SizedBox(
                key: const Key('home_cube_safe_viewport'),
                width: side * 1.42,
                height: side * 1.4,
                child: ClipRect(
                  child: Center(
                    child: FlutterCubeTransition(
                      width: side,
                      height: side,
                      initialRotationY: 0,
                      obliqueFaceContentThreshold: .55,
                      secondsToSwipe: const Duration(seconds: 5),
                      animationDuration: const Duration(milliseconds: 280),
                      animationCurve: Curves.easeOutCubic,
                      enableHapticFeedback: false,
                      perspectiveStrength: .00125,
                      showControls: false,
                      borderVisible: false,
                      faceShadowColor: const Color(0x220D2454),
                      faceShadowBlurRadius: 8,
                      faceShadowSpreadRadius: 0,
                      margin: EdgeInsets.zero,
                      textAlign: Alignment.center,
                      borderRadius: BorderRadius.circular(24),
                      dragSensitivity: .007,
                      dragThreshold: .5,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  CubeFaceData _faceForOffer(UserOfferItem offer) {
    final image = (offer.imageUrl ?? '').trim();
    final rawTitle = (offer.title ?? '').trim();
    final title = rawTitle.isEmpty ? 'تعرّف على خدماتنا' : rawTitle;
    final label = (offer.discountLabel ?? '').trim();
    final rawDescription = (offer.description ?? '').trim();
    final desc = rawDescription.isEmpty
        ? 'اختَر ما يناسبك من خدمات ع الندهة'
        : rawDescription;
    return CubeFaceData(
      color: SharedPlatformColors.primary,
      text: '',
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image.isNotEmpty)
            Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: SharedPlatformColors.primary),
            )
          else
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF172554), Color(0xFF303D81)],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
              ),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xE6172554),
                  Color(0xB9172554),
                  Color(0x70172554),
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
                    const SizedBox(height: 3),
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
                        fontSize: 12,
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
