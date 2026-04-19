import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/restaurant_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_details_screen.dart';
import 'package:dllni_user_app/features/rs_favourite/domain/usecases/toggle_restaurant_favourite_use_case.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/fetch_restaurant_home_nearest_restaurants_model.dart';

class StoreCard extends StatefulWidget {
  const StoreCard({
    super.key,
    required this.store,
    this.onFavouriteChanged,
    this.expandToFit = false,
  });

  final RestaurantHomeNearestRestaurantItem store;
  final void Function(bool isFavorited)? onFavouriteChanged;
  final bool expandToFit;

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  late bool _isFavorited;
  bool _isUpdatingFavourite = false;

  RestaurantHomeNearestRestaurantItem get store => widget.store;

  @override
  void initState() {
    super.initState();
    _isFavorited = store.isFavorited ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final id = store.id;
        if (id == null) return;
        context.pushRoute(
          '/rs_store',
          arguments: StoreDetailsScreenParams(
            restaurantId: id,
            preview: RestaurantPreviewData.fromHomeNearest(
              store,
            ).copyWith(isFavorited: _isFavorited),
          ),
        );
      },
      borderRadius: BorderRadius.all(Radius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          color: context.onPrimaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: Color(0xFFF3F4F6)),
        ),
        width: widget.expandToFit ? double.infinity : 204,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child:
                        store.primaryImageUrl == null ||
                            store.primaryImageUrl!.isEmpty
                        ? Container(
                            width: double.infinity,
                            height: 120,
                            color: const Color(0xFFF5F5F5),
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          )
                        : AppImage.network(
                            store.primaryImageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            height: 120,
                            errorWidget: Container(
                              width: double.infinity,
                              color: const Color(0xFFF5F5F5),
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: InkWell(
                      onTap: _toggleFavourite,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: context.onPrimaryContainer,
                        child: FaIcon(
                          _isFavorited
                              ? FontAwesomeIcons.solidHeart
                              : FontAwesomeIcons.heart,
                          size: 16,
                          color: _isFavorited
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if ((store.discountOfferBadge ?? '').isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryContainer,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.tag,
                                size: 10,
                                color: context.onPrimaryContainer,
                              ),
                              SizedBox(width: 4),
                              AppText(
                                store.discountOfferBadge!,
                                style: TextStyle(
                                  color: context.onPrimaryContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 16 / 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(width: 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              (store.rating ?? 0).toStringAsFixed(1),
                              style: TextStyle(
                                color: Color(0xFF15803D),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 16 / 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            FaIcon(
                              FontAwesomeIcons.solidStar,
                              size: 12,
                              color: Color(0xFF22C55E),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  AppText(
                    store.name ?? ' - ',
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    scrollText: true,
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 24 / 16,
                    ),
                  ),
                  AppText(
                    store.cuisineSummary ?? '-',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                    ),
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavourite() async {
    if (_isUpdatingFavourite) return;
    final restaurantId = store.id;
    if (restaurantId == null || restaurantId <= 0) return;

    final next = !_isFavorited;
    setState(() {
      _isFavorited = next;
    });

    final onFavouriteChanged = widget.onFavouriteChanged;
    if (onFavouriteChanged != null) {
      onFavouriteChanged(next);
      return;
    }

    setState(() {
      _isUpdatingFavourite = true;
    });

    final res = await getIt<ToggleRestaurantFavouriteUseCase>()(
      ToggleRestaurantFavouriteParams(
        restaurantId: restaurantId,
        isFavorited: next,
      ),
    );

    if (!mounted) return;

    res.fold(
      (_) {
        setState(() {
          _isFavorited = !next;
          _isUpdatingFavourite = false;
        });
      },
      (_) {
        setState(() {
          _isUpdatingFavourite = false;
        });
      },
    );
  }
}
