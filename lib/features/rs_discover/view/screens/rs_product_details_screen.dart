import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_share_targets.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../rs_favourite/domain/usecases/toggle_product_favourite_use_case.dart';
import '../../data/models/fetch_restaurant_product_details_model.dart';
import '../../domain/usecases/add_restaurant_cart_item_use_case.dart';
import '../manager/bloc/rs_discover_bloc.dart';
import '../models/product_preview_data.dart';
import '../widgets/product_details_sub_widgets.dart';

class ProductDetailsScreenParams {
  final ProductPreviewData product;

  ProductDetailsScreenParams({required this.product});
}

@AutoRoutePage(path: "/rs_product")
class RsProductDetailsScreen extends StatefulWidget {
  final ProductDetailsScreenParams params;

  const RsProductDetailsScreen({super.key, required this.params});

  @override
  State<RsProductDetailsScreen> createState() => _RsProductDetailsScreenState();
}

class _CartAppBarAction extends StatelessWidget {
  final int cartCount;

  final VoidCallback onTap;

  const _CartAppBarAction({required this.cartCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: const FaIcon(FontAwesomeIcons.cartShopping, size: 18, color: Color(0xFF1A1A1A)),
          ),
          PositionedDirectional(
            top: -2,
            end: -2,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: const Color(0xFFFF7A00),
              child: AppText(
                '$cartCount',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RsProductDetailsScreenState extends State<RsProductDetailsScreen> {
  final TextEditingController notesController = TextEditingController();
  late final RsDiscoverBloc _discoverBloc;
  final PageController _imagePageController = PageController();
  int _quantity = 1;
  int _currentImagePage = 0;
  final List<String> _savedNotes = [];
  final Map<int, Set<int>> _selectedModifierIdsByGroup = {};
  bool _isSubmittingAddToCart = false;
  late bool _isFavorited;
  bool _isUpdatingFavourite = false;
  bool _didSyncRemoteFavourite = false;

  String get _restaurantName {
    final preview = widget.params.product.restaurantName.trim();
    return preview.isNotEmpty ? preview : 'مطعم';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _discoverBloc,
      child: BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
        builder: (context, state) {
          final details = state.productDetails;
          final imageUrls = _imageUrls(details);
          final description = _description(details);
          final displayPrice = _displayPrice(details);
          final oldPrice = _oldPrice(details);
          final modifierGroups = details?.modifierGroups ?? const <RestaurantProductDetailsModifierGroup>[];
          final remoteFavorited = details?.product?.isFavorite;
          if (!_didSyncRemoteFavourite && remoteFavorited != null && remoteFavorited != _isFavorited && !_isUpdatingFavourite) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _isFavorited = remoteFavorited;
                _didSyncRemoteFavourite = true;
              });
            });
          } else if (!_didSyncRemoteFavourite && remoteFavorited != null) {
            _didSyncRemoteFavourite = true;
          }
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            appBar: AppBar(
              forceMaterialTransparency: true,
              title: AppText(
                _name(details),
                style: TextStyle(color: Color(0xFF111827), fontSize: 17, fontWeight: FontWeight.w700, height: 24 / 17),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ProductActionButton(icon: Icons.arrow_back, onTap: () => context.maybePop()),
              ),
              actions: [
                ProductActionButton(
                  icon: _isFavorited ? Icons.favorite : Icons.favorite_outline,
                  iconColor: _isFavorited ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                  onTap: _isUpdatingFavourite ? () {} : _toggleFavourite,
                ),
                SizedBox(width: 8),
                BlocBuilder<CartProductsCountCubit, int>(
                  bloc: getIt<CartProductsCountCubit>(),
                  builder: (context, cartCount) {
                    return _CartAppBarAction(cartCount: cartCount, onTap: () => context.pushRoute('/cart'));
                  },
                ),
                SizedBox(width: 8),
                ProductActionButton(
                  icon: Icons.share,
                  onTap: () {
                    final url = productUrl(widget.params.product.productId);
                    unawaited(shareDeepLinkUrl(url, context: context));
                  },
                ),
                SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
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
                                    child: const Icon(Icons.image_outlined, size: 56, color: Color(0xFF9CA3AF)),
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
                                          color: const Color(0xFFF5F5F5),
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.image_outlined, size: 56, color: Color(0xFF9CA3AF)),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          // Positioned(
                          //   top: 20,
                          //   right: 16,
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.end,
                          //     children: [
                          //       ProductBadge(
                          //         title: "الأكثر طلباً",
                          //         color: Color(0xFFEF4444),
                          //       ),
                          //       SizedBox(height: 8),
                          //       ProductBadge(
                          //         title: "عرض خاص",
                          //         color: Color(0xFF22C55E),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          if (imageUrls.length > 1)
                            Positioned(
                              bottom: 20,
                              right: 16,
                              left: 16,
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: Color(0x80000000), borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(imageUrls.length, (index) {
                                      final isActive = _currentImagePage == index;
                                      return Container(
                                        width: isActive ? 14 : 6,
                                        height: 6,
                                        margin: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 4),
                                        decoration: BoxDecoration(
                                          color: isActive ? Colors.white : Color(0x80FFFFFF),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      color: context.onPrimary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          AppText(
                            _name(details),
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Color(0xFF111827), fontSize: 36 / 2, fontWeight: FontWeight.w700, height: 30 / 18),
                          ),
                          SizedBox(height: 6),
                          AppText(
                            _restaurantName,
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500, height: 22 / 14),
                          ),
                          if (description.isNotEmpty) ...[
                            SizedBox(height: 8),
                            AppText(
                              description,
                              textAlign: TextAlign.start,
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500, height: 20 / 13),
                            ),
                          ],
                          SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsetsDirectional.all(12),
                                decoration: BoxDecoration(color: Color(0xffFEFCE8), borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.solidStar, size: 13, color: Color(0xFFFBBF24)),
                                    SizedBox(width: 6),
                                    AppText(
                                      "4.9",
                                      style: TextStyle(color: Color(0xFF374151), fontSize: 14, fontWeight: FontWeight.w700, height: 20 / 14),
                                    ),
                                    SizedBox(width: 6),
                                    AppText(
                                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500, height: 20 / 13),
                                      "(320 تقييم)",
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 6),
                              Container(
                                padding: EdgeInsetsDirectional.all(12),
                                decoration: BoxDecoration(color: Color(0xffF9FAFB), borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.fire, size: 13, color: context.primaryContainer),
                                    SizedBox(width: 6),
                                    AppText(
                                      "450 مرة طلب",
                                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500, height: 20 / 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                _priceText(displayPrice),
                                style: TextStyle(color: Color(0xFF16A34A), fontSize: 44 / 2, fontWeight: FontWeight.w700, height: 30 / 22),
                              ),
                              if (oldPrice != null)
                                AppText(
                                  _priceText(oldPrice),
                                  style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 24 / 2,
                                    fontWeight: FontWeight.w500,
                                    height: 20 / 12,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                      color: context.onPrimary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            "إضافات اختيارية",
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Color(0xFF111827), fontSize: 32 / 2, fontWeight: FontWeight.w700, height: 24 / 16),
                          ),
                          SizedBox(height: 4),
                          AppText(
                            "اختر ما يناسبك",
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w600, height: 16 / 12),
                          ),
                          SizedBox(height: 16),
                          if (state.isLoadingProductDetails)
                            const Center(child: CircularProgressIndicator())
                          else if (state.productDetailsErrorMessage.isNotEmpty)
                            AppText(
                              state.productDetailsErrorMessage,
                              style: TextStyle(color: Color(0xFFB91C1C), fontSize: 13, fontWeight: FontWeight.w500),
                            )
                          else if (modifierGroups.isEmpty)
                            Center(
                              child: AppText(
                                "لا توجد إضافات متاحة لهذا المنتج",
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            )
                          else
                            ...modifierGroups.map((group) {
                              final selectedIds = _selectedForGroup(group);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ProductModifierGroupCard(
                                  group: group,
                                  selectedModifierIds: selectedIds,
                                  onModifierTap: (modifierId) {
                                    _toggleModifier(group: group, modifierId: modifierId);
                                  },
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                      color: context.onPrimary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            "ملاحظات خاصة",
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Color(0xFF111827), fontSize: 32 / 2, fontWeight: FontWeight.w700, height: 24 / 16),
                          ),
                          SizedBox(height: 4),
                          AppText(
                            "أضف اي طلب خاص",
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w600, height: 16 / 12),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: notesController,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _saveCurrentNote(),
                            style: TextStyle(color: Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
                            decoration: InputDecoration(
                              hintText: "اكتب ملاحظة خاصة بالطلب (اختياري)",
                              hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w500, height: 20 / 13),
                              contentPadding: EdgeInsets.all(16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(14)),
                                borderSide: BorderSide(width: 1.5, color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(14)),
                                borderSide: BorderSide(width: 1.5, color: Color(0xFFE5E7EB)),
                              ),
                            ),
                          ),
                          if (_savedNotes.isNotEmpty) ...[
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(_savedNotes.length, (index) {
                                return ProductSavedNoteChip(label: _savedNotes[index], onRemove: () => _removeSavedNote(index));
                              }),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: ProductBottomBar(
              quantity: _quantity,
              isSubmitting: _isSubmittingAddToCart,
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
              onAddPressed: _isSubmittingAddToCart ? () {} : _onAddToCartPressed,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    _imagePageController.dispose();
    _discoverBloc.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.params.product.isFavorited;
    _discoverBloc = getIt<RsDiscoverBloc>();
    if (widget.params.product.productId > 0) {
      _discoverBloc.add(FetchRestaurantProductDetailsEvent(productId: widget.params.product.productId));
    }
  }

  String _description(FetchRestaurantProductDetailsModel? details) {
    return details?.product?.description?.trim().isNotEmpty == true ? details!.product!.description!.trim() : widget.params.product.description;
  }

  num? _displayPrice(FetchRestaurantProductDetailsModel? details) {
    return details?.product?.discountedPrice ?? details?.product?.price ?? widget.params.product.displayPrice;
  }

  List<String> _imageUrls(FetchRestaurantProductDetailsModel? details) {
    final urls = <String>[];
    final primary = details?.product?.primaryImage?.trim();
    if (primary != null && primary.isNotEmpty) {
      urls.add(primary);
    }
    final extraImages = details?.product?.images ?? const <String>[];
    for (final image in extraImages) {
      final trimmed = image.trim();
      if (trimmed.isEmpty || urls.contains(trimmed)) continue;
      urls.add(trimmed);
    }
    final preview = widget.params.product.imageUrl?.trim();
    if (urls.isEmpty && preview != null && preview.isNotEmpty) {
      urls.add(preview);
    }
    return urls;
  }

  String _name(FetchRestaurantProductDetailsModel? details) {
    return details?.product?.name?.trim().isNotEmpty == true ? details!.product!.name!.trim() : widget.params.product.name;
  }

  num? _oldPrice(FetchRestaurantProductDetailsModel? details) {
    final detailsProduct = details?.product;
    if (detailsProduct?.discountedPrice != null && detailsProduct?.price != null) {
      return detailsProduct!.price;
    }
    return widget.params.product.originalPrice;
  }

  Future<void> _onAddToCartPressed() async {
    if (_isSubmittingAddToCart) return;
    final productId = widget.params.product.productId;
    if (productId <= 0) {
      AppToast.showToast(context: context, message: 'تعذر تحديد المنتج', type: ToastificationType.error);
      return;
    }

    final modifierIds = _selectedModifierIdsByGroup.values.expand((ids) => ids).toSet().toList()..sort();
    final currentNote = notesController.text.trim();
    final specialInstructions = currentNote.isNotEmpty ? currentNote : (_savedNotes.isNotEmpty ? _savedNotes.join('\n') : '');

    setState(() {
      _isSubmittingAddToCart = true;
    });

    final response = await getIt<AddRestaurantCartItemUseCase>()(
      AddRestaurantCartItemParams(
        productId: productId,
        quantity: _quantity,
        modifierIds: modifierIds,
        substituteProductId: null,
        specialInstructions: specialInstructions,
      ),
    );

    if (!mounted) return;

    response.fold(
      (failure) {
        setState(() {
          _isSubmittingAddToCart = false;
        });
        AppToast.showToast(context: context, message: failure.message, type: ToastificationType.error);
      },
      (result) {
        setState(() {
          _isSubmittingAddToCart = false;
        });
        getIt<CartProductsCountCubit>().refreshAfterAdd();
        AppToast.showToast(
          context: context,
          message: (result.message ?? '').trim().isNotEmpty ? result.message! : 'تمت إضافة المنتج إلى السلة',
          type: ToastificationType.success,
        );
      },
    );
  }

  String _priceText(num? value) {
    if (value == null) return '-';
    final clean = value % 1 == 0 ? value.toInt().toString() : value.toString();
    final currency = (widget.params.product.currency ?? '').trim();
    return currency.isEmpty ? clean : '$clean $currency';
  }

  void _removeSavedNote(int index) {
    if (index < 0 || index >= _savedNotes.length) return;
    setState(() {
      _savedNotes.removeAt(index);
    });
  }

  void _saveCurrentNote() {
    final note = notesController.text.trim();
    if (note.isEmpty) return;
    setState(() {
      _savedNotes.add(note);
      notesController.clear();
    });
  }

  Set<int> _selectedForGroup(RestaurantProductDetailsModifierGroup group) {
    final id = group.id;
    if (id == null) return <int>{};
    return _selectedModifierIdsByGroup[id] ?? <int>{};
  }

  Future<void> _toggleFavourite() async {
    if (_isUpdatingFavourite) return;
    final productId = widget.params.product.productId;
    if (productId <= 0) return;

    final next = !_isFavorited;
    setState(() {
      _isFavorited = next;
      _isUpdatingFavourite = true;
    });

    final res = await getIt<ToggleProductFavouriteUseCase>()(ToggleProductFavouriteParams(productId: productId, isFavorited: next));

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

  void _toggleModifier({required RestaurantProductDetailsModifierGroup group, required int modifierId}) {
    final groupId = group.id;
    if (groupId == null) return;
    final current = {...(_selectedModifierIdsByGroup[groupId] ?? <int>{})};
    final has = current.contains(modifierId);
    if (group.maxSelections <= 1) {
      current
        ..clear()
        ..add(modifierId);
      if (has) {
        current.clear();
      }
    } else {
      if (has) {
        current.remove(modifierId);
      } else {
        if (group.maxSelections > 0 && current.length >= group.maxSelections) {
          return;
        }
        current.add(modifierId);
      }
    }
    setState(() {
      _selectedModifierIdsByGroup[groupId] = current;
    });
  }
}
