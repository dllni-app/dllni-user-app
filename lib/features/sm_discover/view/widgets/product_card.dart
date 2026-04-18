import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../profile/domain/usecases/add_shopping_list_item_use_case.dart';
import '../../../profile/domain/usecases/get_shopping_list_use_case.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../../sm_stores/view/manager/bloc/sm_stores_bloc.dart';
import '../../../sm_stores/view/screens/sm_product_details_screen.dart';
import '../../data/models/browse_products_model.dart';
import '../../domain/usecases/change_product_favorite_use_case.dart';
import '../manager/bloc/sm_discover_bloc.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product});
  final BrowseProductsModelDataItem product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavorite;
  bool isAddingToShoppingList = false;
  late SmStoresBloc _smStoresBloc;

  @override
  void initState() {
    isFavorite = widget.product.isFavorite ?? false;
    _smStoresBloc = getIt<SmStoresBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _smStoresBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _smStoresBloc,
      child: GestureDetector(
        onTap: () async {
          if (widget.product.id == null) return;
          final navImageUrl = widget.product.imageUrl?.trim().isNotEmpty == true
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
                    AppImage.network(
                      widget.product.imageUrl ?? '',
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
                            widget.product.name.toString(), //"ربطة خبز سياحي",
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 20 / 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          AppText(
                            "وزن ${widget.product.description} غ",
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 16 / 12,
                            ),
                          ),
                          SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (widget.product.discountedPrice !=
                                      null) ...[
                                    AppText(
                                      "${widget.product.price} ل.س",
                                      style: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        height: 16 / 12,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                  ],
                                  AppText(
                                    "${widget.product.discountedPrice ?? widget.product.price} ل.س",
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      height: 16 / 12,
                                    ),
                                  ),
                                ],
                              ),
                              Flexible(
                                child: Container(
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
                                    widget.product.store?.name.toString() ??
                                        "null",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      height: 16 / 12,
                                    ),
                                  ),
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
              if (widget.product.discountedPrice != null)
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
              Positioned(
                top: 4,
                left: 4,
                child: BlocProvider(
                  create: (context) => getIt<SmDiscoverBloc>(),
                  child: BlocListener<SmDiscoverBloc, SmDiscoverState>(
                    listenWhen: (previous, current) =>
                        previous.changeProductFavoriteStatus !=
                        current.changeProductFavoriteStatus,
                    listener: (context, state) {
                      if (state.changeProductFavoriteStatus ==
                          BlocStatus.failed) {
                        isFavorite = !isFavorite;
                        setState(() {});
                        AppToast.showToast(
                          context: context,
                          message: state.errorMessage.toString(),
                          type: ToastificationType.error,
                        );
                      }
                    },
                    child: InkWell(
                      onTap: () {
                        isFavorite = !isFavorite;
                        setState(() {});
                        context.read<SmDiscoverBloc>().add(
                          ChangeProductFavoriteEvent(
                            params: ChangeProductFavoriteParams(
                              productId: widget.product.id ?? 0,
                              isFavorite: isFavorite,
                            ),
                          ),
                        );
                      },
                      customBorder: CircleBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: FaIcon(
                          isFavorite
                              ? FontAwesomeIcons.solidHeart
                              : FontAwesomeIcons.heart,
                          size: 16,
                          color: isFavorite
                              ? Colors.red
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isAddingToShoppingList)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .2),
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _addProductToShoppingList() async {
  //   if (isAddingToShoppingList) return;
  //   final shoppingListId = widget.shoppingListId;
  //   final masterProductId = widget.product.masterProductId;
  //   if (shoppingListId == null || masterProductId == null) return;
  //   isAddingToShoppingList = true;
  //   setState(() {});

  //   final res = await getIt<AddShoppingListItemUseCase>()(
  //     AddShoppingListItemParams(
  //       shoppingListId: shoppingListId,
  //       masterProductId: masterProductId,
  //       quantity: 1,
  //     ),
  //   );
  //   if (!mounted) return;
  //   res.fold(
  //     (failure) {
  //       AppToast.showToast(
  //         context: context,
  //         message: failure.message,
  //         type: ToastificationType.error,
  //       );
  //     },
  //     (_) {
  //       getIt<ProfileBloc>().add(
  //         GetShoppingListEvent(params: GetShoppingListParams()),
  //       );
  //       if (!mounted) return;
  //       AppToast.showToast(
  //         context: context,
  //         message: 'تمت إضافة المنتج إلى القائمة',
  //         type: ToastificationType.success,
  //       );
  //     },
  //   );
  //   isAddingToShoppingList = false;
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }
}
