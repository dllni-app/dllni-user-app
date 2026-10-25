import 'dart:async';

import 'package:flutter/material.dart';
import '../../data/models/fetch_user_offers_model.dart';
import '../../../../core/themes/shared_platform_colors.dart';

/// A lightweight, aspect-ratio-preserving alternative to the 3D offer cube.
///
/// Empty offers render one honest platform discovery panel. We never repeat an
/// offer simply to populate fake faces or animate a single card.
class HomeOfferCarousel extends StatefulWidget {
  const HomeOfferCarousel({super.key, required this.offers});

  final List<UserOfferItem> offers;

  @override
  State<HomeOfferCarousel> createState() => _HomeOfferCarouselState();
}

class _HomeOfferCarouselState extends State<HomeOfferCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _configureRotation();
  }

  @override
  void didUpdateWidget(covariant HomeOfferCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offers.length != widget.offers.length) {
      _index = 0;
      if (_controller.hasClients) _controller.jumpToPage(0);
      _configureRotation();
    }
  }

  void _configureRotation() {
    _timer?.cancel();
    if (widget.offers.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.offers.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Maintain a landscape promotional proportion on all phone sizes.
        final height = (constraints.maxWidth / 1.9).clamp(150.0, 204.0);
        final offers = widget.offers;
        return Column(
          children: [
            SizedBox(
              height: height,
              child: offers.isEmpty
                  ? const _PlatformDiscoveryPanel()
                  : PageView.builder(
                      key: const Key('home_offers_carousel'),
                      controller: _controller,
                      itemCount: offers.length,
                      onPageChanged: (index) => setState(() => _index = index),
                      itemBuilder: (context, index) =>
                          _OfferPanel(offer: offers[index]),
                    ),
            ),
            if (offers.length > 1) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  offers.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 22 : 6,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: i == _index
                          ? SharedPlatformColors.primary
                          : SharedPlatformColors.muted.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PlatformDiscoveryPanel extends StatelessWidget {
  const _PlatformDiscoveryPanel();

  @override
  Widget build(BuildContext context) {
    return const _PromotionSurface(
      icon: Icons.auto_awesome_rounded,
      title: 'كل اللي تحتاجه، بمكان واحد',
      description:
          'تنظيف، مطاعم، تسوّق وتوصيل. اختَر خدمتك وخلّي يومك أسهل مع ع الندهة.',
    );
  }
}

class _OfferPanel extends StatelessWidget {
  const _OfferPanel({required this.offer});
  final UserOfferItem offer;

  @override
  Widget build(BuildContext context) {
    final image = (offer.imageUrl ?? '').trim();
    return _PromotionSurface(
      image: image,
      title: (offer.title ?? '').trim().isEmpty
          ? 'اكتشف خدمات ع الندهة'
          : offer.title!.trim(),
      description: (offer.description ?? '').trim().isEmpty
          ? 'خدمات تناسب يومك، من أول طلب حتى متابعة التفاصيل.'
          : offer.description!.trim(),
      eyebrow: (offer.discountLabel ?? '').trim(),
    );
  }
}

class _PromotionSurface extends StatelessWidget {
  const _PromotionSurface({
    this.image = '',
    this.icon,
    required this.title,
    required this.description,
    this.eyebrow = '',
  });
  final String image;
  final IconData? icon;
  final String title;
  final String description;
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $description',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF132044), Color(0xFF273F80)],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
              ),
            ),
            if (image.isNotEmpty)
              Image.network(
                image,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xEC132044),
                    Color(0x9E132044),
                    Color(0x42132044),
                  ],
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (eyebrow.isNotEmpty) ...[
                          Text(
                            eyebrow,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFA2EEF0),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFF3F6FE),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 10),
                    Icon(icon, color: const Color(0xFFA2EEF0), size: 46),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
