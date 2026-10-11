import 'package:flutter/material.dart';
import '../../../../core/themes/shared_platform_colors.dart';
import '../../../../core/themes/v7_artwork.dart';
import '../../data/models/fetch_user_offers_model.dart';
import 'home_cube.dart';

/// Default is the V7 flat editorial campaign carousel.
/// Build with --dart-define=ALNADHA_AD_STYLE=cube to activate the
/// updated four-face cube without changing any booking/API code.
enum V7CampaignStyle { editorial, cube }

abstract final class V7CampaignConfig {
  static const style = String.fromEnvironment(
    'ALNADHA_AD_STYLE',
    defaultValue: 'editorial',
  );
  static const selected = style == 'cube'
      ? V7CampaignStyle.cube
      : V7CampaignStyle.editorial;
}

class V7CampaignPresenter extends StatelessWidget {
  const V7CampaignPresenter({super.key, required this.offers, this.style});
  final List<UserOfferItem> offers;
  final V7CampaignStyle? style;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();
    if ((style ?? V7CampaignConfig.selected) == V7CampaignStyle.cube) {
      return HomeCube(offers: offers);
    }
    return _EditorialOffers(offers: offers);
  }
}

class _EditorialOffers extends StatefulWidget {
  const _EditorialOffers({required this.offers});
  final List<UserOfferItem> offers;

  @override
  State<_EditorialOffers> createState() => _EditorialOffersState();
}

class _EditorialOffersState extends State<_EditorialOffers> {
  final PageController controller = PageController();
  int active = 0;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.offers;
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: controller,
            itemCount: items.length,
            onPageChanged: (page) => setState(() => active = page),
            itemBuilder: (context, index) {
              final offer = items[index];
              final title = (offer.title ?? '').trim();
              final desc = (offer.description ?? '').trim();
              final discount = (offer.discountLabel ?? '').trim();
              final image = (offer.imageUrl ?? '').trim();
              return Semantics(
                label: [
                  title,
                  desc,
                  discount,
                ].where((s) => s.isNotEmpty).join('، '),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (image.isNotEmpty)
                        Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Image.asset(
                            V7Artwork.cleaningPhoto,
                            fit: BoxFit.cover,
                          ),
                          loadingBuilder: (context, child, event) =>
                              event == null
                              ? child
                              : ColoredBox(
                                  color: SharedPlatformColors.neutralSoft,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: event.expectedTotalBytes == null
                                          ? null
                                          : event.cumulativeBytesLoaded /
                                                event.expectedTotalBytes!,
                                    ),
                                  ),
                                ),
                        )
                      else
                        Image.asset(V7Artwork.cleaningPhoto, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xD9142349),
                              Color(0x55142349),
                              Color(0x090F172A),
                            ],
                            begin: AlignmentDirectional.centerStart,
                            end: AlignmentDirectional.centerEnd,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 240),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (discount.isNotEmpty) ...[
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: SharedPlatformColors.cleaning,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        discount,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: Color(0xFF142349),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 9),
                                ],
                                if (title.isNotEmpty)
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w900,
                                      height: 1.4,
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
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (items.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              items.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: active == index ? 22 : 6,
                decoration: BoxDecoration(
                  color: active == index
                      ? SharedPlatformColors.primary
                      : SharedPlatformColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
