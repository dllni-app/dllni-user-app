import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../sm_discover/domain/usecases/change_product_favorite_use_case.dart';
import '../../../sm_discover/view/manager/bloc/sm_discover_bloc.dart';
import '../../data/models/sm_store_product_summary.dart';
import '../screens/sm_product_details_screen.dart';
import 'package:toastification/toastification.dart';

class ProductCard extends StatefulWidget {
  final SmStoreProductSummary product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavorite;
  late SmDiscoverBloc _bloc;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.product.isFavorite ?? false;
    _bloc = getIt<SmDiscoverBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product.imageUrl?.trim().isNotEmpty == true
        ? widget.product.imageUrl!
        : (widget.product.image?.url ?? '').trim();
    final discountedStr = widget.product.discountedPrice == null
        ? ''
        : widget.product.discountedPrice.toString().trim();
    final priceStr = (widget.product.price ?? '').trim();
    final hasDiscount = discountedStr.isNotEmpty && discountedStr != priceStr;

    return Container(
      width: context.width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 8,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    AppImage.network(
                      imageUrl,
                      height: 112,
                      width: 112,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      fit: BoxFit.cover,
                      errorWidget: Icon(Icons.error_outline),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            widget.product.name ?? '',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 24 / 16,
                            ),
                          ),
                          if (widget.product.description != null &&
                              widget.product.description
                                  .toString()
                                  .trim()
                                  .isNotEmpty) ...[
                            SizedBox(height: 8),
                            AppText(
                              widget.product.description.toString().trim(),
                              style: TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 16 / 12,
                              ),
                            ),
                          ],
                          SizedBox(height: 24),
                          Row(
                            spacing: 20,
                            children: [
                              if (hasDiscount)
                                AppText(
                                  "$priceStr ل.س",
                                  style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 20 / 14,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Color(0xFF9CA3AF),
                                  ),
                                ),
                              AppText(
                                "${hasDiscount ? discountedStr : priceStr} ل.س",
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 28 / 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _ProductButton(
                  onTap: () async {
                    if (widget.product.id == null) return;
                    final navImageUrl =
                        widget.product.imageUrl?.trim().isNotEmpty == true
                        ? widget.product.imageUrl!
                        : (widget.product.image?.url ?? '').trim();
                    final result = await context.pushRoute(
                      "/product",
                      arguments: SmProductDetailsScreenArgs(
                        productId: widget.product.id!,
                        starter: SmStarterProductDetailsData(
                          name: widget.product.name,
                          imageUrl: navImageUrl.isNotEmpty ? navImageUrl : null,
                          price: widget.product.price,
                          discountedPrice: widget.product.discountedPrice
                              ?.toString()
                              .trim(),
                          isFavorite: widget.product.isFavorite,
                        ),
                      ),
                    );
                    if (result != null && result is bool) {
                      isFavorite = result;
                      widget.product.isFavorite = isFavorite;
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
          if (hasDiscount)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: AppText(
                  "عرض اليوم",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 15 / 10,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: BlocListener<SmDiscoverBloc, SmDiscoverState>(
              bloc: _bloc,
              listener: (context, state) {
                if (state.changeProductFavoriteStatus == BlocStatus.failed) {
                  isFavorite = !isFavorite;
                  setState(() {});
                  AppToast.showToast(
                    context: context,
                    message: state.errorMessage.toString(),
                    type: ToastificationType.error,
                  );
                }
              },
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                  _bloc.add(
                    ChangeProductFavoriteEvent(
                      params: ChangeProductFavoriteParams(
                        productId: widget.product.id ?? 0,
                        isFavorite: isFavorite,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 11.5,
                  backgroundColor: Color(0x1CCD0C0C),
                  child: FaIcon(
                    isFavorite
                        ? FontAwesomeIcons.solidHeart
                        : FontAwesomeIcons.heart,
                    size: 9,
                    color: Color(0xFFCF0E0E),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductButton extends StatelessWidget {
  final void Function() onTap;

  const _ProductButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.plus, size: 12, color: AppColors.white),
            AppText(
              "إضافة للسلة",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 20 / 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
