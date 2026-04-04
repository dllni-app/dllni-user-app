import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../rs_discover/view/models/product_preview_data.dart';
import '../../../rs_discover/view/screens/rs_product_details_screen.dart';

import '../../data/models/fetch_restaurant_home_suggested_products_model.dart';
import '../manager/bloc/rs_home_bloc.dart';

class SuggestedProductsSection extends StatelessWidget {
  const SuggestedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<RsHomeBloc, RsHomeState>(
        builder: (context, state) {
          final status = state.restaurantSuggestedProductsStatus;
          final list =
              state.restaurantSuggestedProducts?.suggestedProducts ?? const [];
          if (status == BlocStatus.loading ||
              status == null ||
              status == BlocStatus.init) {
            return const SizedBox(
              height: 140,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (status == BlocStatus.failed) {
            return const SizedBox.shrink();
          }
          if (list.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppText(
                    "مقترح لك",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF273C8F),
                    ),
                  ),
                  SizedBox(width: 8),
                  FaIcon(
                    FontAwesomeIcons.wandMagicSparkles,
                    size: 16,
                    color: context.primaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AppText(
                "اخترنا لك أفضل الأطباق بناءً على ذوقك",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  height: 22 / 15,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length,
                  itemBuilder: (_, index) =>
                      _SuggestedProductCard(item: list[index]),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SuggestedProductCard extends StatelessWidget {
  const _SuggestedProductCard({required this.item});

  final RestaurantHomeSuggestedProductItem item;

  @override
  Widget build(BuildContext context) {
    final productId = item.productId;
    final subtitle = _restaurantAndLocationText(item);
    final tags = item.tags ?? const <String>[];

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      onTap: productId == null
          ? null
          : () {
              context.pushRoute(
                '/product',
                arguments: ProductDetailsScreenParams(
                  product: ProductPreviewData.fromSuggestedItem(item),
                ),
              );
            },
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: context.onPrimaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child:
                        item.primaryImageUrl == null ||
                            item.primaryImageUrl!.isEmpty
                        ? Container(
                            width: double.infinity,
                            color: const Color(0xFFF5F5F5),
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          )
                        : AppImage.network(
                            item.primaryImageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
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
                  PositionedDirectional(
                    top: 12,
                    end: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (item.rating ?? 0).toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFF273C8F),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 20 / 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFBBC05),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 28 / 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _priceText(item.displayPrice, item.currency),
                          style: const TextStyle(
                            color: Color(0xFF273C8F),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 26 / 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                      ),
                    ),
                  ],
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags
                          .where((tag) => tag.trim().isNotEmpty)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 16 / 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
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

String _priceText(num? price, String? currency) {
  if (price == null) return '-';
  final cleanedPrice = price % 1 == 0
      ? price.toInt().toString()
      : price.toString();
  final cleanedCurrency = (currency ?? '').trim();
  if (cleanedCurrency.isEmpty) return cleanedPrice;
  return '$cleanedPrice $cleanedCurrency';
}

String? _restaurantAndLocationText(RestaurantHomeSuggestedProductItem item) {
  final restaurant = item.restaurantName?.trim();
  final location = item.location?.trim();
  final hasRestaurant = restaurant != null && restaurant.isNotEmpty;
  final hasLocation = location != null && location.isNotEmpty;

  if (hasRestaurant && hasLocation) {
    return '$restaurant - $location';
  }
  if (hasRestaurant) return restaurant;
  if (hasLocation) return location;
  return null;
}
