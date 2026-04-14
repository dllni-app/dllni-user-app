import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/product_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/fetch_restaurant_home_latest_ordered_products_model.dart';
import '../manager/bloc/rs_home_bloc.dart';

String _priceText(num? price, String? currency) {
  if (price == null) return '-';
  final cleanedPrice = price % 1 == 0
      ? price.toInt().toString()
      : price.toString();
  final cleanedCurrency = (currency ?? '').trim();
  if (cleanedCurrency.isEmpty) return cleanedPrice;
  return '$cleanedPrice $cleanedCurrency';
}

class LatestOrderedProductsSection extends StatelessWidget {
  const LatestOrderedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<RsHomeBloc, RsHomeState>(
        builder: (context, state) {
          final status = state.restaurantLatestOrderedProductsStatus;
          final list =
              state.restaurantLatestOrderedProducts?.latestOrderedProducts ??
              const [];
          final isReorderLoading =
              state.restaurantReorderStatus == BlocStatus.loading;
          if (status == BlocStatus.failed) {
            return const SizedBox.shrink();
          }
          if (status == BlocStatus.loading ||
              status == null ||
              status == BlocStatus.init) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (list.isEmpty) {
            return const SizedBox.shrink();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          "اطلب مجدداً",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        SizedBox(height: 2),
                        AppText.labelSmall(
                          'يمكنك اعادة طلب طلبك الاخير',
                          color: Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: isReorderLoading
                        ? null
                        : () {
                            context.read<RsHomeBloc>().add(
                              ReorderLatestOrderedProductEvent(),
                            );
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: context.primary,
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: isReorderLoading
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.onPrimary,
                              ),
                            )
                          : AppText.labelLarge(
                              'اعد الطلب',
                              color: context.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...list.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LatestOrderedProductCard(item: item),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LatestOrderedProductCard extends StatelessWidget {
  final RestaurantHomeLatestOrderedProductItem item;

  const _LatestOrderedProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final productId = item.productId;

    return InkWell(
      onTap: productId == null || productId <= 0
          ? null
          : () {
              context.pushRoute(
                '/rs_product',
                arguments: ProductDetailsScreenParams(
                  product: ProductPreviewData.fromLatestOrderedItem(item),
                ),
              );
            },
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          color: context.onPrimary,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child:
                    item.primaryImageUrl == null ||
                        item.primaryImageUrl!.isEmpty
                    ? Container(
                        width: 88,
                        height: 88,
                        color: const Color(0xFFF5F5F5),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF9CA3AF),
                        ),
                      )
                    : AppImage.network(
                        item.primaryImageUrl!,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: 88,
                          height: 88,
                          color: const Color(0xFFF5F5F5),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.restaurantName ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 20 / 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        AppText(
                          _priceText(item.displayPrice, item.currency),
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Color(0xFF273C8F),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 34 / 34,
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
      ),
    );
  }
}
