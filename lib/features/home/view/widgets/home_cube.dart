
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/home/data/models/fetch_user_offers_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cube_transition/flutter_cube_transition.dart';

class HomeCube extends StatefulWidget {
  final List<UserOfferItem> offers;

  const HomeCube({super.key, required this.offers});

  @override
  State<HomeCube> createState() => _HomeCubeState();
}

class _HomeCubeState extends State<HomeCube> {
  static const List<CubeFace> _faceOrder = [
    CubeFace.front,
    CubeFace.back,
    CubeFace.right,
    CubeFace.left,
  ];

  @override
  Widget build(BuildContext context) {
    final offers = widget.offers;
    if (offers.isEmpty) {
      return Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
        child: SizedBox(
          width: context.width * .8,
          height: context.width * .42,
          child: Center(
            child: AppText.bodyMedium(
              'لا توجد عروض حالياً',
              color: Color(0xff6B7280),
            ),
          ),
        ),
      );
    }

    final padded = List<UserOfferItem>.generate(
      _faceOrder.length,
      (i) => offers[i % offers.length],
    );

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10),
      child: FlutterCubeTransition(
        // width: context.width * 0.65,
        // height: context.height * 0.25,
        // secondsToSwipe: Duration(seconds: 5),
          size:  context.width * 0.5,

        animationDuration: Duration(milliseconds: 400),
        animationCurve: Curves.easeOut,
        enableHapticFeedback: true,
        perspectiveStrength: 0.002,
        showControls: false,
        borderVisible: false,
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        textAlign: Alignment.topLeft,
        borderRadius: BorderRadius.circular(16),
        dragSensitivity: 0.006,
        dragThreshold: 0.6,
        onRotationChanged: (_) {},
        faceTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black87, offset: Offset(2, 2), blurRadius: 6),
          ],
        ),
        faces: {
          for (var i = 0; i < _faceOrder.length; i++)
            _faceOrder[i]: _faceForOffer(padded[i]),
        },
      ),
    );
  }

  CubeFaceData _faceForOffer(UserOfferItem offer) {
    final base = _themeColor(offer.theme);
    final imageUrl = offer.imageUrl;
    return CubeFaceData(
      color: Colors.grey.shade200,
      text: offer.discountLabel ?? offer.title ?? '',
      borderRadius: BorderRadius.circular(16),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? SizedBox.expand(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: base,
                    child: Center(
                      child: Icon(
                        Icons.local_offer_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 48,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return ColoredBox(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(color: base),
                    ),
                  );
                },
              ),
            )
          : SizedBox.expand(
              child: ColoredBox(
                color: base,
                child: Center(
                  child: Icon(
                    Icons.local_offer_outlined,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 48,
                  ),
                ),
              ),
            ),
    );
  }

  Color _themeColor(String? theme) {
    switch (theme) {
      case 'orange':
        return const Color(0xFFE65100);
      case 'gold':
        return const Color(0xFFC6A035);
      case 'green':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF212C7E);
    }
  }
}
