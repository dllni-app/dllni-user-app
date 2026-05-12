import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_share_targets.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/widgets/failure_widget.dart';
import '../../../rs_discover/view/widgets/product_details_sub_widgets.dart';
import '../../../sm_cart/view/screens/sm_cart_screen.dart';
import '../../../sm_discover/domain/usecases/change_product_favorite_use_case.dart';
import '../../../sm_discover/view/manager/bloc/sm_discover_bloc.dart';
import '../../data/models/get_supermarket_product_details_model.dart';
import '../../domain/usecases/get_compare_products_use_case.dart';
import '../manager/bloc/sm_stores_bloc.dart';
import '../widgets/dialogs/related_products_dialog.dart';
import '../widgets/dialogs/shopping_lists_dialog.dart';

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

String _smDescriptionText(SupermarketProductDetailsProduct? product) {
  final d = product?.description;
  if (d == null) return '';
  if (d is String) return d.trim();
  return d.toString().trim();
}

List<String> _smImageUrls(
  SupermarketProductDetailsProduct? product,
  SmStarterProductDetailsData? starter,
) {
  final urls = <String>[];
  void add(String? u) {
    final t = (u ?? '').trim();
    if (t.isEmpty || urls.contains(t)) return;
    urls.add(t);
  }

  if (product != null) {
    add(product.primaryImage);
    add(product.imageUrl);
    add(product.image?.url);
    add(product.image?.thumbnailUrl);
    for (final u in product.imageUrls ?? const <String>[]) {
      add(u);
    }
    for (final im in product.images ?? const <SupermarketProductDetailsMedia>[]) {
      add(im.url);
      add(im.thumbnailUrl);
    }
  }
  add(starter?.imageUrl);
  return urls;
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
  final TextEditingController _notesController = TextEditingController();
  final PageController _imagePageController = PageController();
  final List<String> _savedNotes = <String>[];
  int _currentImagePage = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _favoriteLocal = widget.args.starter?.isFavorite ?? false;
    _bloc = getIt<SmDiscoverBloc>();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _imagePageController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _openCompareDialog(BuildContext context) {
    context.read<SmStoresBloc>().add(
          GetCompareProductsEvent(
            isReload: true,
            params: GetCompareProductsParams(
              productId: widget.args.productId,
            ),
          ),
        );
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<SmStoresBloc>(),
        child: RelatedProductsDialog(
          productId: widget.args.productId,
        ),
      ),
    );
  }

  void _openShoppingListsDialog(BuildContext context) {
    final masterId = widget.args.starter?.masterId ??
        context.read<SmStoresBloc>().state.productDetails?.masterProductId;
    if (masterId == null || masterId <= 0) {
      AppToast.showToast(
        context: context,
        message: 'تعذر تحديد المنتج',
        type: ToastificationType.error,
      );
      return;
    }
    context.read<SmStoresBloc>().add(LoadShoppingListsEvent());
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<SmStoresBloc>(),
        child: ShoppingListsDialog(masterProductId: masterId),
      ),
    );
  }

  void _saveCurrentNote() {
    final note = _notesController.text.trim();
    if (note.isEmpty) return;
    setState(() {
      _savedNotes.add(note);
      _notesController.clear();
    });
  }

  void _removeSavedNote(int index) {
    if (index < 0 || index >= _savedNotes.length) return;
    setState(() {
      _savedNotes.removeAt(index);
    });
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

          final imageUrls = _smImageUrls(product, starter);

          final displayStore =
              product?.store?.name?.trim() ?? starter?.storeName?.trim() ?? '';
          final displayTitle = product?.name?.trim().isNotEmpty == true
              ? product!.name!.trim()
              : starter?.name?.trim() ?? '';
          final displayStoreLine =
              displayStore.isNotEmpty ? displayStore : 'متجر';

          final description = _smDescriptionText(product);

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
              backgroundColor: const Color(0xFFF9FAFB),
              appBar: AppBar(
                forceMaterialTransparency: true,
                title: AppText(
                  displayTitle.isEmpty ? ' ' : displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 24 / 17,
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ProductActionButton(
                    icon: Icons.arrow_back,
                    onTap: () => context.pop<bool>(_favoriteLocal),
                  ),
                ),
                actions: [
                  BlocListener<SmDiscoverBloc, SmDiscoverState>(
                    bloc: _bloc,
                    listener: (context, discoverState) {
                      if (discoverState.changeProductFavoriteStatus ==
                          BlocStatus.failed) {
                        setState(() {
                          _favoriteLocal = !_favoriteLocal;
                        });
                        AppToast.showToast(
                          context: context,
                          message: discoverState.errorMessage.toString(),
                          type: ToastificationType.error,
                        );
                      }
                    },
                    child: ProductActionButton(
                      icon: _favoriteLocal
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      iconColor: _favoriteLocal
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF6B7280),
                      onTap: () {
                        setState(() {
                          _favoriteLocal = !_favoriteLocal;
                        });
                        _bloc.add(
                          ChangeProductFavoriteEvent(
                            params: ChangeProductFavoriteParams(
                              productId: widget.args.productId,
                              isFavorite: _favoriteLocal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ProductActionButton(
                    icon: Icons.compare_arrows,
                    onTap: () => _openCompareDialog(context),
                  ),
                  const SizedBox(width: 8),
                  ProductActionButton(
                    icon: Icons.playlist_add,
                    onTap: () => _openShoppingListsDialog(context),
                  ),
                  const SizedBox(width: 8),
                  ProductActionButton(
                    icon: Icons.shopping_cart_outlined,
                    onTap: () => context.pushRoute(
                      '/cart',
                      arguments: SmCartScreenParams(initialSectionIndex: 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ProductActionButton(
                    icon: Icons.share,
                    onTap: () {
                      final id = widget.args.productId;
                      if (id <= 0) return;
                      unawaited(
                        shareDeepLinkUrl(
                          productUrl(id),
                          context: context,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: showFullScreenLoading
                  ? const Center(child: CircularProgressIndicator())
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
                      : SafeArea(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 350,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: imageUrls.isEmpty
                                            ? Container(
                                                color: const Color(0xFFF5F5F5),
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.image_outlined,
                                                  size: 56,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                              )
                                            : PageView.builder(
                                                controller: _imagePageController,
                                                itemCount: imageUrls.length,
                                                onPageChanged: (index) {
                                                  setState(() {
                                                    _currentImagePage = index;
                                                  });
                                                },
                                                itemBuilder: (_, index) {
                                                  return AppImage.network(
                                                    imageUrls[index],
                                                    fit: BoxFit.cover,
                                                    errorWidget: Container(
                                                      color: const Color(
                                                          0xFFF5F5F5),
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Icon(
                                                        Icons.image_outlined,
                                                        size: 56,
                                                        color:
                                                            Color(0xFF9CA3AF),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                      if (state.productDetailsStatus ==
                                              BlocStatus.success &&
                                          (product?.offers?.isNotEmpty ??
                                              false))
                                        Positioned(
                                          bottom: 20,
                                          right: 16,
                                          child: const ProductBadge(
                                            title: 'الأكثر طلباً',
                                            color: Color(0xFF22C55E),
                                          ),
                                        ),
                                      if (imageUrls.length > 1)
                                        Positioned(
                                          bottom: 20,
                                          right: 16,
                                          left: 16,
                                          child: Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0x80000000),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: List.generate(
                                                  imageUrls.length,
                                                  (index) {
                                                    final isActive =
                                                        _currentImagePage ==
                                                            index;
                                                    return Container(
                                                      width:
                                                          isActive ? 14 : 6,
                                                      height: 6,
                                                      margin: EdgeInsetsDirectional
                                                          .only(
                                                        start: index == 0
                                                            ? 0
                                                            : 4,
                                                      ),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: isActive
                                                            ? Colors.white
                                                            : const Color(
                                                                0x80FFFFFF,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(999),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  color: context.onPrimary,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      AppText(
                                        displayTitle,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          height: 30 / 18,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      AppText(
                                        displayStoreLine,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          height: 22 / 14,
                                        ),
                                      ),
                                      if (description.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        AppText(
                                          description,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            height: 20 / 13,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsetsDirectional
                                                .all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffFEFCE8),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                const FaIcon(
                                                  FontAwesomeIcons.solidStar,
                                                  size: 13,
                                                  color: Color(0xFFFBBF24),
                                                ),
                                                const SizedBox(width: 6),
                                                AppText(
                                                  product?.store
                                                              ?.averageRating
                                                              ?.trim()
                                                              .isNotEmpty ==
                                                          true
                                                      ? product!
                                                          .store!
                                                          .averageRating!
                                                          .trim()
                                                      : '4.9',
                                                  style: const TextStyle(
                                                    color: Color(0xFF374151),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    height: 20 / 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                AppText(
                                                  product?.store?.totalReviews !=
                                                          null
                                                      ? '(${product!.store!.totalReviews} تقييم)'
                                                      : '(320 تقييم)',
                                                  style: const TextStyle(
                                                    color: Color(0xFF6B7280),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    height: 20 / 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsetsDirectional
                                                .all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffF9FAFB),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons.fire,
                                                  size: 13,
                                                  color: context
                                                      .primaryContainer,
                                                ),
                                                const SizedBox(width: 6),
                                                AppText(
                                                  '450 مرة طلب',
                                                  style: const TextStyle(
                                                    color: Color(0xFF6B7280),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    height: 20 / 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AppText(
                                            priceMainText.isEmpty
                                                ? '-'
                                                : priceMainText,
                                            style: const TextStyle(
                                              color: Color(0xFF16A34A),
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              height: 30 / 22,
                                            ),
                                          ),
                                          if (priceStrikeText != null)
                                            AppText(
                                              priceStrikeText,
                                              style: const TextStyle(
                                                color: Color(0xFF9CA3AF),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                height: 20 / 12,
                                                decoration: TextDecoration
                                                    .lineThrough,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
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
                                                productId:
                                                    widget.args.productId,
                                              ),
                                            );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 22,
                                  ),
                                  color: context.onPrimary,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText(
                                        'ملاحظات خاصة',
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          height: 24 / 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      AppText(
                                        'أضف اي طلب خاص',
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          height: 16 / 12,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _notesController,
                                        maxLines: 3,
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) =>
                                            _saveCurrentNote(),
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          height: 20 / 14,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText:
                                              'اكتب ملاحظة خاصة بالطلب (اختياري)',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF9CA3AF),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            height: 20 / 13,
                                          ),
                                          contentPadding: EdgeInsets.all(16),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(14),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1.5,
                                              color: Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(14),
                                            ),
                                            borderSide: BorderSide(
                                              width: 1.5,
                                              color: Color(0xFFE5E7EB),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_savedNotes.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: List.generate(
                                            _savedNotes.length,
                                            (index) {
                                              return ProductSavedNoteChip(
                                                label: _savedNotes[index],
                                                onRemove: () =>
                                                    _removeSavedNote(index),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
              bottomNavigationBar: showFullScreenLoading ||
                      showFullScreenFailure
                  ? null
                  : ProductBottomBar(
                      quantity: _quantity,
                      isSubmitting:
                          state.addToCartStatus == BlocStatus.loading,
                      onDecrease: () {
                        if (_quantity == 1) return;
                        setState(() {
                          _quantity -= 1;
                        });
                      },
                      onIncrease: () {
                        setState(() {
                          _quantity += 1;
                        });
                      },
                      onAddPressed: () {
                        context.read<SmStoresBloc>().add(
                              AddSupermarketCartItemEvent(
                                productId: widget.args.productId,
                                quantity: _quantity,
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
