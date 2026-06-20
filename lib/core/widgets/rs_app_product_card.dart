import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/rs_discover/data/models/fetch_restaurant_products_search_model.dart';
import '../../features/rs_discover/domain/usecases/add_restaurant_cart_item_use_case.dart';
import '../di/injection.dart';

class RsAppProductCard extends StatefulWidget {
  const RsAppProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.restaurant,
    required this.price,
    required this.onTap,
    this.isInCart = false,
    required this.productId,
    required this.offer,
  });

  final String image;
  final String title;
  final String restaurant;
  final String price;
  final int productId;
  final Function() onTap;
  final bool isInCart;
  final FetchRestaurantProductsSearchModelActiveOffer? offer;

  @override
  State<RsAppProductCard> createState() => _RsAppProductCardState();
}

class _RsAppProductCardState extends State<RsAppProductCard> {
  bool isInCart = false;

  @override
  void initState() {
    super.initState();
    isInCart = widget.isInCart;
  }

  @override
  Widget build(BuildContext context) {
    final safeImage = widget.image.trim();

    return Container(
      width: 166,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffF3F4F6), width: 1),
        color: context.onPrimary,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: widget.onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      safeImage.isEmpty
                          ? Container(
                              width: context.width,
                              height: 100,
                              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
                            )
                          : AppImage.network(
                              safeImage,
                              width: context.width,
                              height: 100,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(16),
                              errorWidget: Container(
                                width: context.width,
                                height: 100,
                                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
                              ),
                            ),
                      const SizedBox(height: 12),
                      Row(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: AppText.bodyMedium(widget.title, fontWeight: FontWeight.bold, maxLines: 1, scrollText: true)),
                          if (widget.offer?.badgeText != null)
                            Container(
                              decoration: BoxDecoration(color: context.primaryContainer.withAlpha(51), borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
                              child: AppText.labelMedium(
                                widget.offer!.badgeText!,
                                color: context.primaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AppText.bodyMedium(
                        widget.restaurant,
                        fontWeight: FontWeight.w400,
                        maxLines: 1,
                        scrollText: true,
                        color: const Color(0xff6B7280),
                      ),
                      const SizedBox(height: 6),
                      AppText.bodyMedium(
                        widget.price,
                        fontWeight: FontWeight.bold,
                        maxLines: 1,
                        color: const Color(0xff1E2A78),
                      ),
                    ],
                  ),
                ),
                if (widget.offer?.title != null)
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.primaryContainer,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
                      child: AppText.labelSmall(widget.offer!.title!, fontWeight: FontWeight.bold, color: context.onPrimaryContainer),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  isInCart = true;
                });
                _onAddToCartPressed(widget.productId);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isInCart ? context.onPrimary : context.primary,
                  border: isInCart ? Border.all(color: context.primary) : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText.bodyMedium(
                  isInCart ? 'تم الطلب' : 'طلب الوجبة',
                  color: isInCart ? context.primary : context.onPrimary,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAddToCartPressed(int id) async {
    await getIt<AddRestaurantCartItemUseCase>()(AddRestaurantCartItemParams(productId: id, quantity: 1));
  }
}
