import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';
import '../../../sm_discover/domain/usecases/change_product_favorite_use_case.dart';
import '../../../sm_discover/view/manager/bloc/sm_discover_bloc.dart';
import '../../data/models/get_compare_products_model.dart';
import '../screens/sm_product_details_screen.dart';
import 'package:toastification/toastification.dart';

class ProductCard2 extends StatefulWidget {
  const ProductCard2({super.key, required this.item});

  final GetCompareProductsModelDataItem item;

  @override
  State<ProductCard2> createState() => _ProductCard2State();
}

class _ProductCard2State extends State<ProductCard2> {
  bool isFavorite = false;
  late SmDiscoverBloc _bloc;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.item.isFavorite ?? false;
    _bloc = getIt<SmDiscoverBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = (widget.item.imageUrl ?? '').trim();
    final discountedStr = widget.item.discountedPrice == null
        ? ''
        : widget.item.discountedPrice.toString().trim();
    final priceStr = (widget.item.price ?? '').trim();
    final hasDiscount = discountedStr.isNotEmpty && discountedStr != priceStr;
    final categoryName = widget.item.category?.name?.trim();
    final desc = widget.item.description == null
        ? ''
        : widget.item.description.toString().trim();
    final showOfferBadge = widget.item.offers?.isNotEmpty == true;

    return GestureDetector(
      onTap: () async {
        if (widget.item.id == null) return;
        final navImageUrl = widget.item.imageUrl?.trim().isNotEmpty == true
            ? widget.item.imageUrl!
            : (widget.item.image?.url ?? '').trim();
        final result = await context.pushRoute(
          "/product",
          arguments: SmProductDetailsScreenArgs(
            productId: widget.item.id!,
            starter: SmStarterProductDetailsData(
              masterId: widget.item.masterProductId,
              name: widget.item.name,
              imageUrl: navImageUrl.isNotEmpty ? navImageUrl : null,
              price: widget.item.price,
              discountedPrice: widget.item.discountedPrice?.toString().trim(),
              isFavorite: widget.item.isFavorite,
            ),
          ),
        );
        if (result != null && result is bool) {
          isFavorite = result;
          widget.item.isFavorite = isFavorite;
          setState(() {});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: AppColors.white),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 23, 11, 13),
              child: Row(
                spacing: 12,
                children: [
                  imageUrl.isNotEmpty
                      ? AppImage.network(
                          imageUrl,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          errorWidget: Icon(Icons.error_outline, size: 32),
                        )
                      : AppImage.asset(
                          AppImages.products,
                          size: 80,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12),
                        AppText(
                          widget.item.name ?? '',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 20 / 14,
                          ),
                        ),
                        if (desc.isNotEmpty) ...[
                          SizedBox(height: 8),
                          AppText(
                            desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 16 / 12,
                            ),
                          ),
                        ],
                        SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (hasDiscount)
                              AppText(
                                "$priceStr ل.س",
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 16 / 12,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Color(0xFF9CA3AF),
                                ),
                              ),
                            if (hasDiscount) SizedBox(width: 16),
                            AppText(
                              "${hasDiscount ? discountedStr : priceStr} ل.س",
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 16 / 12,
                              ),
                            ),
                            if (categoryName != null &&
                                categoryName.isNotEmpty) ...[
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(
                                    alpha: .08,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                                child: AppText(
                                  categoryName,
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 16 / 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showOfferBadge)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                  child: AppText(
                    "عرض لفترة محدودة",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 15 / 10,
                    ),
                  ),
                ),
              ),
            BlocListener<SmDiscoverBloc, SmDiscoverState>(
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
              child: Positioned(
                top: 4,
                left: 4,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                    _bloc.add(
                      ChangeProductFavoriteEvent(
                        params: ChangeProductFavoriteParams(
                          productId: widget.item.id ?? 0,
                          isFavorite: isFavorite,
                        ),
                      ),
                    );
                  },
                  customBorder: CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: FaIcon(FontAwesomeIcons.heart, size: 16),
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
