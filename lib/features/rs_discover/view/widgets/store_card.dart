import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/rs_favourite/domain/usecases/toggle_restaurant_favourite_use_case.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/restaurant_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_store_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/fetch_discover_restaurants_model.dart';

class StoreCard extends StatefulWidget {
  const StoreCard({super.key, required this.store});

  final FetchDiscoverRestaurantsModelDataItem store;

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  late bool _isFavorited;
  bool _isUpdatingFavourite = false;

  FetchDiscoverRestaurantsModelDataItem get store => widget.store;

  @override
  void initState() {
    super.initState();
    _isFavorited = store.isFavorited ?? false;
  }

  String? get _imageUrl {
    final u = store.imageUrl;
    if (u != null && u.isNotEmpty) return u;
    final p = store.primaryImage;
    if (p != null && p.isNotEmpty) return p;
    final i = store.image;
    if (i != null && i.isNotEmpty) return i;
    return null;
  }

  String get _subtitle {
    final types = store.cuisineTypes
        ?.map((e) => e.name)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();
    if (types != null && types.isNotEmpty) {
      return types.join(' • ');
    }
    return store.description ?? '';
  }

  int get _discountPercent {
    final offer = store.listingOffer;
    if (offer == null) return 0;
    if (offer.discountType == 'percentage' && offer.discountValue != null) {
      return offer.discountValue!.round();
    }
    return 0;
  }

  String get _timeLabel {
    final m = store.estimatedPreparationTime;
    if (m == null) return '—';
    return '$m دقيقة';
  }

  String get _distanceLabel {
    final d = store.distanceKm;
    if (d == null) return '—';
    return '${d.toStringAsFixed(1)} كم';
  }

  String get _minimumLabel {
    final m = store.minimumOrderAmount;
    if (m == null) return '—';
    return '${m.toString()} حد أدنى';
  }

  @override
  Widget build(BuildContext context) {
    final rating = store.averageRating ?? 0;
    final imageUrl = _imageUrl;

    return InkWell(
      onTap: () {
        final id = store.id;
        if (id == null) return;
        context.pushRoute(
          '/rs_store',
          arguments: StoreDetailsScreenParams(
            restaurantId: id,
            preview: RestaurantPreviewData.fromDiscover(store).copyWith(isFavorited: _isFavorited),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.onPrimaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: Color(0xFFF3F4F6)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              fit: StackFit.loose,
              children: [
                imageUrl != null &&
                        (imageUrl.startsWith('http://') ||
                            imageUrl.startsWith('https://'))
                    ? AppImage.network(
                        imageUrl,
                        height: 160,
                        width: context.width,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: context.width,
                          height: 160,
                          color: const Color(0xFFF5F5F5),
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      )
                    : (imageUrl != null && imageUrl.isNotEmpty
                          ? AppImage.asset(
                              imageUrl,
                              height: 160,
                              width: context.width,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: context.width,
                              height: 160,
                              color: const Color(0xFFF5F5F5),
                              child: Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                            )),
                Positioned(
                  top: 12,
                  left: 12,
                  child: InkWell(
                    onTap: _toggleFavourite,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: context.onPrimaryContainer,
                      child: FaIcon(
                        _isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                        size: 16,
                        color: _isFavorited ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                if (_discountPercent > 0)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.primaryContainer,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
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
                            "خصم $_discountPercent%",
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
                  ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.onPrimaryContainer,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          _timeLabel,
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 16 / 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        FaIcon(
                          FontAwesomeIcons.motorcycle,
                          size: 15,
                          color: Color(0xFF6C63FF),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText(
                          store.name ?? '',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 24 / 16,
                          ),
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
                              rating.toStringAsFixed(1),
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
                    _subtitle,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.locationArrow,
                        size: 12,
                        color: Color(0xB26C63FF),
                      ),
                      SizedBox(width: 8),
                      AppText(
                        _distanceLabel,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          height: 16 / 12,
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        radius: 2,
                        backgroundColor: Color(0xFFD1D5DB),
                      ),
                      SizedBox(width: 8),
                      AppText(
                        _minimumLabel,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          height: 16 / 12,
                        ),
                      ),
                    ],
                  ),
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
