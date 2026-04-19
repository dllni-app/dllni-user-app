import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../sm_discover/domain/usecases/change_product_favorite_use_case.dart';
import '../../../sm_discover/view/manager/bloc/sm_discover_bloc.dart';
import '../../data/models/get_supermarket_product_details_model.dart';
import '../../domain/usecases/get_compare_products_use_case.dart';
import '../manager/bloc/sm_stores_bloc.dart';
import '../widgets/dialogs/related_products_dialog.dart';
import '../widgets/dialogs/shopping_lists_dialog.dart';
import '../widgets/products_bottom_nav_bar.dart';
import 'package:toastification/toastification.dart';

String _smStoresTrim(dynamic value) =>
    value == null ? '-' : value.toString().trim();

(String, String?) _smProductDetailsPriceLines({
  required SupermarketProductDetailsProduct? product,
  required SmStarterProductDetailsData? starter,
}) {
  if (product != null && product.hasDiscount == true) {
    final fp = product.finalPrice?.trim() ?? '';
    final dp = _smStoresTrim(product.discountedPrice);
    final pr = product.price?.trim() ?? '';
    final mainRaw = fp.isNotEmpty ? fp : (dp.isNotEmpty ? dp : pr);
    final main = mainRaw.isEmpty ? '' : '$mainRaw ل.س';
    final op = _smStoresTrim(product.originalPrice);
    final strikeRaw = op.isNotEmpty ? op : pr;
    return (main, strikeRaw.isEmpty ? null : '$strikeRaw ل.س');
  }
  if (product != null) {
    final fp = product.finalPrice?.trim() ?? '';
    final pr = product.price?.trim() ?? '';
    final raw = fp.isNotEmpty ? fp : pr;
    return (raw.isEmpty ? '' : '$raw ل.س', null);
  }
  if (starter != null) {
    final spr = (starter.price ?? '').trim();
    final sdi = (starter.discountedPrice ?? '').trim();
    if (sdi.isNotEmpty && sdi != spr) {
      return ('$sdi ل.س', spr.isEmpty ? null : '$spr ل.س');
    }
    return (spr.isEmpty ? '' : '$spr ل.س', null);
  }
  return ('', null);
}

class SmStarterProductDetailsData {
  final int? masterId;
  final String? name;
  final String? storeName;
  final String? imageUrl;
  final String? price;
  final String? discountedPrice;
  final bool? isFavorite;

  const SmStarterProductDetailsData({
    required this.masterId,
    this.name,
    this.storeName,
    this.imageUrl,
    this.price,
    this.discountedPrice,
    this.isFavorite,
  });
}

class SmProductDetailsScreenArgs {
  final int productId;
  final SmStarterProductDetailsData? starter;

  const SmProductDetailsScreenArgs({required this.productId, this.starter});
}

@AutoRoutePage(path: "/product")
class SmProductDetailsScreen extends StatefulWidget {
  const SmProductDetailsScreen({super.key, required this.args});

  final SmProductDetailsScreenArgs args;

  @override
  State<SmProductDetailsScreen> createState() => _SmProductDetailsScreenState();
}

class _SmProductDetailsScreenState extends State<SmProductDetailsScreen> {
  bool _favoriteLocal = false;
  late SmDiscoverBloc _bloc;

  @override
  void initState() {
    super.initState();
    _favoriteLocal = widget.args.starter?.isFavorite ?? false;
    _bloc = getIt<SmDiscoverBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SmStoresBloc>()
        ..add(
          LoadSupermarketProductDetailsEvent(productId: widget.args.productId),
        ),
      child: BlocConsumer<SmStoresBloc, SmStoresState>(
        listener: (context, state) {
          if (state.productDetailsStatus == BlocStatus.success &&
              state.productDetails != null) {
            setState(() {
              _favoriteLocal = state.productDetails!.isFavorite ?? false;
            });
          }
          if (state.addToCartStatus == BlocStatus.success) {
            AppToast.showToast(
              context: context,
              message: state.addToCartMessage ?? 'تمت إضافة المنتج إلى السلة',
              type: ToastificationType.success,
            );
          } else if (state.addToCartStatus == BlocStatus.failed) {
            AppToast.showToast(
              context: context,
              message:
                  state.addToCartErrorMessage ?? 'تعذر إضافة المنتج إلى السلة',
              type: ToastificationType.error,
            );
          }
        },
        builder: (context, state) {
          final product = state.productDetails;
          final starter = widget.args.starter;
          final productStatus = state.productDetailsStatus;
          final loadingProduct =
              productStatus == BlocStatus.loading ||
              productStatus == BlocStatus.init;
          final failedProduct = productStatus == BlocStatus.failed;

          final showFullScreenLoading =
              loadingProduct && product == null && starter == null;
          final showFullScreenFailure =
              failedProduct && product == null && starter == null;

          final (priceMainText, priceStrikeText) = _smProductDetailsPriceLines(
            product: product,
            starter: starter,
          );

          final heroUrl = product != null
              ? (product.imageUrl ?? '').trim()
              : (starter?.imageUrl ?? '').trim();

          final displayStore =
              product?.store?.name?.trim() ?? starter?.storeName?.trim() ?? '';
          final displayTitle =
              product?.name?.trim() ?? starter?.name?.trim() ?? '';

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!context.mounted) return;
                  context.pop<bool>(_favoriteLocal);
                });
              }
            },
            child: Scaffold(
              body: showFullScreenLoading
                  ? Center(child: CircularProgressIndicator())
                  : showFullScreenFailure
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: FailureWidget(
                          message: state.errorMessage ?? '',
                          onRetry: () {
                            context.read<SmStoresBloc>().add(
                              LoadSupermarketProductDetailsEvent(
                                productId: widget.args.productId,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 340 + MediaQuery.paddingOf(context).top,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: AppImage.network(
                                    heroUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: Icon(
                                      Icons.broken_image_outlined,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: MediaQuery.paddingOf(context).top + 32,
                                  left: 24,
                                  right: 24,
                                  child: Row(
                                    spacing: 5,
                                    children: [
                                      _ActionButton(
                                        icon: FontAwesomeIcons.arrowRight,
                                        onTap: () =>
                                            context.pop<bool>(_favoriteLocal),
                                      ),
                                      Expanded(
                                        child: AppText(
                                          displayStore,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Color(0xFF111827),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            height: 24 / 16,
                                          ),
                                        ),
                                      ),
                                      BlocListener<
                                        SmDiscoverBloc,
                                        SmDiscoverState
                                      >(
                                        bloc: _bloc,
                                        listener: (context, state) {
                                          if (state
                                                  .changeProductFavoriteStatus ==
                                              BlocStatus.failed) {
                                            setState(() {
                                              _favoriteLocal = !_favoriteLocal;
                                            });
                                            AppToast.showToast(
                                              context: context,
                                              message: state.errorMessage
                                                  .toString(),
                                              type: ToastificationType.error,
                                            );
                                          }
                                        },
                                        child: _ActionButton(
                                          icon: _favoriteLocal
                                              ? FontAwesomeIcons.solidHeart
                                              : FontAwesomeIcons.heart,
                                          onTap: () {
                                            setState(() {
                                              _favoriteLocal = !_favoriteLocal;
                                            });
                                            _bloc.add(
                                              ChangeProductFavoriteEvent(
                                                params:
                                                    ChangeProductFavoriteParams(
                                                      productId:
                                                          widget.args.productId,
                                                      isFavorite:
                                                          _favoriteLocal,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      _ActionButton(
                                        icon: FontAwesomeIcons.shareNodes,
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 24,
                                  left: 24,
                                  child: _ActionButton(
                                    icon: FontAwesomeIcons.add,
                                    onTap: () {
                                      final masterId =
                                          widget.args.starter?.masterId ??
                                          context
                                              .read<SmStoresBloc>()
                                              .state
                                              .productDetails
                                              ?.masterProductId;
                                      if (masterId == null || masterId <= 0) {
                                        AppToast.showToast(
                                          context: context,
                                          message: 'تعذر تحديد المنتج',
                                          type: ToastificationType.error,
                                        );
                                        return;
                                      }
                                      context.read<SmStoresBloc>().add(
                                        LoadShoppingListsEvent(),
                                      );
                                      showDialog<void>(
                                        context: context,
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<SmStoresBloc>(),
                                          child: ShoppingListsDialog(
                                            masterProductId: masterId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (state.productDetailsStatus ==
                                        BlocStatus.success &&
                                    (product?.offers?.isNotEmpty ?? false))
                                  Positioned(
                                    bottom: 20,
                                    right: 16,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 22,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, 4),
                                            blurRadius: 6,
                                            spreadRadius: -4,
                                            color: Color(0x1A000000),
                                          ),
                                          BoxShadow(
                                            offset: Offset(0, 10),
                                            blurRadius: 15,
                                            spreadRadius: -3,
                                            color: Color(0x1A000000),
                                          ),
                                        ],
                                      ),
                                      child: AppText(
                                        "الأكثر طلباً",
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          height: 16 / 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(color: Color(0xFFF3F4F6)),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppText(
                                        displayTitle,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          height: 32 / 20,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    InkWell(
                                      onTap: () {
                                        context.read<SmStoresBloc>().add(
                                          GetCompareProductsEvent(
                                            isReload: true,
                                            params: GetCompareProductsParams(
                                              productId: widget.args.productId,
                                            ),
                                          ),
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (_) => BlocProvider.value(
                                            value: context.read<SmStoresBloc>(),
                                            child: RelatedProductsDialog(
                                              productId: widget.args.productId,
                                            ),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 11,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0, 4),
                                              blurRadius: 6,
                                              spreadRadius: -4,
                                              color: Color(0x1A000000),
                                            ),
                                            BoxShadow(
                                              offset: Offset(0, 10),
                                              blurRadius: 15,
                                              spreadRadius: -3,
                                              color: Color(0x1A000000),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          "مقارنة السعر",
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            height: 16 / 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppText(
                                      priceMainText,
                                      style: TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        height: 36 / 30,
                                      ),
                                    ),
                                    if (priceStrikeText != null)
                                      AppText(
                                        priceStrikeText,
                                        style: TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          height: 28 / 18,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (failedProduct &&
                              product == null &&
                              starter != null)
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: FailureWidget(
                                message: state.errorMessage ?? '',
                                onRetry: () {
                                  context.read<SmStoresBloc>().add(
                                    LoadSupermarketProductDetailsEvent(
                                      productId: widget.args.productId,
                                    ),
                                  );
                                },
                              ),
                            ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(color: Color(0xFFF3F4F6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                AppText(
                                  "ملاحظات خاصة",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    height: 28 / 18,
                                  ),
                                ),
                                SizedBox(height: 4),
                                AppText(
                                  "أضف أي طلب خاص",
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 20 / 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                TextField(
                                  maxLines: 3,
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 20 / 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        "اكتب ملاحظة خاصة بالطلب (اختياري)\nمثل: يرجى اختيار ربطة خبز تازة",
                                    hintStyle: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 20 / 14,
                                    ),
                                    contentPadding: EdgeInsets.all(16),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Color(0xFFE5E7EB),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
              bottomNavigationBar: ProductsBottomNavBar(
                isSubmitting: state.addToCartStatus == BlocStatus.loading,
                onAddToCart: (quantity) {
                  context.read<SmStoresBloc>().add(
                    AddSupermarketCartItemEvent(
                      productId: widget.args.productId,
                      quantity: quantity,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final FaIconData icon;
  final void Function() onTap;
  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: FaIcon(icon, size: 18, color: Color(0xFF1F2937)),
      ),
    );
  }
}
