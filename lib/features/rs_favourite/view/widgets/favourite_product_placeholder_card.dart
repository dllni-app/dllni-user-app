import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/product_preview_data.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_product_details_screen.dart';
import 'package:dllni_user_app/features/rs_discover/view/models/store_product_item.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FavouriteProductPlaceholderCard extends StatefulWidget {
  const FavouriteProductPlaceholderCard({super.key, required this.product, this.onAddToCart, this.onFavouriteChanged});

  final StoreProductItem product;
  final Future<void> Function()? onAddToCart;
  final void Function(bool isFavorited)? onFavouriteChanged;

  @override
  State<FavouriteProductPlaceholderCard> createState() => _FavouriteProductPlaceholderCardState();
}

class _FavouriteProductPlaceholderCardState extends State<FavouriteProductPlaceholderCard> {
  bool _isSubmittingAdd = false;
  late bool _isFavorited;

  StoreProductItem get product => widget.product;

  @override
  void initState() {
    super.initState();
    _isFavorited = product.isFavorited;
  }

  Future<void> _handleAddTap() async {
    if (_isSubmittingAdd) return;
    final callback = widget.onAddToCart;
    if (callback == null) return;

    setState(() {
      _isSubmittingAdd = true;
    });

    try {
      await callback();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingAdd = false;
        });
      }
    }
  }

  bool get _hasActiveOffer => product.isOfferActive == true;

  void _toggleFavourite() {
    final next = !_isFavorited;
    setState(() {
      _isFavorited = next;
    });
    widget.onFavouriteChanged?.call(next);
  }

  String? get _offerSubtitle {
    if (!_hasActiveOffer) return null;
    final name = product.offerName?.trim();
    final urgency = product.offerBadgeText?.trim().replaceAll('_', ' ');
    if (name != null && name.isNotEmpty) {
      return urgency != null && urgency.isNotEmpty ? '$name • $urgency' : name;
    }
    if (urgency != null && urgency.isNotEmpty) return urgency;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasValidProductId = (product.id ?? 0) > 0;
    return InkWell(
      onTap: hasValidProductId
          ? () => context.pushRoute('/rs_product', arguments: ProductDetailsScreenParams(product: ProductPreviewData.fromStoreProduct(product)))
          : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: context.onPrimary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 18, 14, 14),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (product.imageUrl ?? '').trim().isEmpty
                          ? Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
                            )
                          : AppImage.network(
                              product.imageUrl!,
                              width: 112,
                              height: 112,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
                              errorWidget: Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF)),
                              ),
                            ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 17, fontWeight: FontWeight.w700, height: 24 / 17),
                            ),
                            const SizedBox(height: 8),
                            AppText(
                              product.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                AppText(
                                  product.priceText,
                                  style: const TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w700, height: 28 / 18),
                                ),
                                const SizedBox(width: 8),
                                if (product.oldPriceText != null)
                                  AppText(
                                    product.oldPriceText!,
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 24 / 16,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                            if (_offerSubtitle != null) ...[
                              const SizedBox(height: 8),
                              AppText(
                                _offerSubtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w700, height: 16 / 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: widget.onAddToCart == null || _isSubmittingAdd ? null : _handleAddTap,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: Color(0xff1E2A78), borderRadius: BorderRadius.circular(10)),
                      child: AppText(
                        _isSubmittingAdd ? 'جاري الإضافة...' : 'اضافة الى السلة',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (product.offerUrgencyTag != null)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF7A00),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomRight: Radius.circular(16)),
                  ),
                  child: AppText(
                    product.offerUrgencyTag!,
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, height: 16 / 11),
                  ),
                ),
              ),
            PositionedDirectional(
              top: 12,
              start: 12,
              child: InkWell(
                onTap: _toggleFavourite,
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: context.onPrimary,
                  child: FaIcon(
                    _isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                    size: 16,
                    color: _isFavorited ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
