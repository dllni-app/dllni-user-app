import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../data/models/fetch_restaurant_details_model.dart';
import '../../domain/usecases/add_restaurant_cart_item_use_case.dart';
import '../../domain/usecases/fetch_restaurant_details_use_case.dart';
import '../models/product_preview_data.dart';
import '../models/store_product_item.dart';
import 'rs_product_details_screen.dart';

@AutoRoutePage(path: "/store-all-products")
class SmStoreAllProductsScreen extends StatefulWidget {
  const SmStoreAllProductsScreen({super.key, required this.restaurantId});

  final int restaurantId;

  @override
  State<SmStoreAllProductsScreen> createState() => _SmStoreAllProductsScreenState();
}

class _SmStoreAllProductsScreenState extends State<SmStoreAllProductsScreen> {
  int _selectedFilterIndex = 0;
  late final Future<FetchRestaurantDetailsModel?> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<FetchRestaurantDetailsModel?> _loadDetails() async {
    final useCase = getIt<FetchRestaurantDetailsUseCase>();
    final res = await useCase(FetchRestaurantDetailsParams(restaurantId: widget.restaurantId));
    return res.fold((_) => null, (r) => r);
  }

  String _formatPrice(num? value) {
    if (value == null) return '—';
    return '${value.toStringAsFixed(2)} د.أ';
  }

  List<StoreProductItem> _buildProducts(FetchRestaurantDetailsModel? details) {
    final byCategories = details?.categories.expand((c) => c.products.map((p) => (product: p, category: c.name))).toList() ?? const [];
    if (byCategories.isNotEmpty) {
      return byCategories.map((entry) {
        final p = entry.product;
        return StoreProductItem(
          id: p.id,
          name: p.name ?? 'منتج',
          description: p.description ?? 'بدون وصف',
          priceText: _formatPrice(p.discountedPrice ?? p.price),
          oldPriceText: p.discountedPrice != null ? _formatPrice(p.price) : null,
          displayPriceValue: p.discountedPrice ?? p.price,
          oldPriceValue: p.discountedPrice != null ? p.price : null,
          imageUrl: p.imageUrl ?? p.primaryImage ?? p.image,
          category: entry.category ?? p.categoryName ?? 'أخرى',
          isTop: p.isFeatured ?? false,
        );
      }).toList();
    }
    final popular = details?.popularProducts ?? const [];
    return popular.map((p) {
      return StoreProductItem(
        id: p.id,
        name: p.name ?? 'منتج',
        description: p.description ?? 'بدون وصف',
        priceText: _formatPrice(p.discountedPrice ?? p.price),
        oldPriceText: p.discountedPrice != null ? _formatPrice(p.price) : null,
        displayPriceValue: p.discountedPrice ?? p.price,
        oldPriceValue: p.discountedPrice != null ? p.price : null,
        imageUrl: p.imageUrl ?? p.primaryImage ?? p.image,
        category: p.categoryName ?? 'الأكثر طلباً',
        isTop: p.isFeatured ?? true,
      );
    }).toList();
  }

  List<String> _buildFilters(List<StoreProductItem> products) {
    final categories = products.map((e) => e.category).toSet().toList();
    return <String>['الكل', 'الأكثر طلباً', ...categories];
  }

  List<StoreProductItem> _filteredProducts(List<StoreProductItem> products, List<String> filters) {
    if (filters.isEmpty) return products;
    final safeIndex = _selectedFilterIndex >= filters.length ? 0 : _selectedFilterIndex;
    final selectedFilter = filters[safeIndex];
    if (selectedFilter == 'الكل') {
      return products;
    }
    return products.where((product) => product.category == selectedFilter || (selectedFilter == 'الأكثر طلباً' && product.isTop)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FetchRestaurantDetailsModel?>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        final products = _buildProducts(snapshot.data);
        final filters = _buildFilters(products);
        final safeIndex = _selectedFilterIndex >= filters.length ? 0 : _selectedFilterIndex;
        if (safeIndex != _selectedFilterIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _selectedFilterIndex = safeIndex;
            });
          });
        }
        final filteredProducts = _filteredProducts(products, filters);
        return Scaffold(
          backgroundColor: context.onPrimary,
          appBar: AppBar(
            backgroundColor: context.onPrimary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: AppText(
              'كل المنتجات',
              style: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final isSelected = _selectedFilterIndex == index;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: isSelected ? context.primary : Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
                        child: AppText(
                          filters[index],
                          style: TextStyle(color: isSelected ? context.onPrimary : Color(0xFF4B5563), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: AppText(
                          'لا توجد منتجات حالياً',
                          style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12),
                        itemBuilder: (_, index) => _AllProductsCard(product: filteredProducts[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AllProductsCard extends StatefulWidget {
  const _AllProductsCard({required this.product});

  final StoreProductItem product;

  @override
  State<_AllProductsCard> createState() => _AllProductsCardState();
}

class _AllProductsCardState extends State<_AllProductsCard> {
  bool _isSubmittingAdd = false;

  StoreProductItem get product => widget.product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushRoute('/product', arguments: ProductDetailsScreenParams(product: ProductPreviewData.fromStoreProduct(product))),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: context.onPrimary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Color(0xFFF3F4F6)),
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
                      SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Color(0xFF1F2937), fontSize: 34 / 2, fontWeight: FontWeight.w700, height: 24 / 17),
                              ),
                              SizedBox(height: 8),
                              AppText(
                                product.description,
                                maxLines: 2,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  AppText(
                                    product.priceText,
                                    style: TextStyle(color: Color(0xFF111827), fontSize: 36 / 2, fontWeight: FontWeight.w700, height: 28 / 18),
                                  ),
                                  SizedBox(width: 8),
                                  if (product.oldPriceText != null)
                                    AppText(
                                      product.oldPriceText!,
                                      style: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 24 / 16,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  InkWell(
                    onTap: _isSubmittingAdd ? null : _onAddToCartPressed,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: context.primary, borderRadius: BorderRadius.circular(10)),
                      child: AppText(
                        _isSubmittingAdd ? 'جاري الإضافة...' : 'اضافة الى السلة',
                        style: TextStyle(color: context.onPrimary, fontSize: 16, fontWeight: FontWeight.w700, height: 24 / 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(0xFFFF7A00),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomRight: Radius.circular(16)),
                ),
                child: AppText(
                  'عرض اليوم',
                  style: TextStyle(color: context.onPrimary, fontSize: 11, fontWeight: FontWeight.w700, height: 16 / 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAddToCartPressed() async {
    if (_isSubmittingAdd) return;
    final productId = product.id;
    if (productId == null || productId <= 0) {
      AppToast.showToast(
        context: context,
        message: 'تعذر تحديد المنتج',
        type: ToastificationType.error,
      );
      return;
    }

    setState(() {
      _isSubmittingAdd = true;
    });

    final res = await getIt<AddRestaurantCartItemUseCase>()(
      AddRestaurantCartItemParams(
        productId: productId,
        quantity: 1,
        modifierIds: const [],
        substituteProductId: null,
        specialInstructions: '',
      ),
    );

    if (!mounted) return;

    res.fold(
      (failure) {
        setState(() {
          _isSubmittingAdd = false;
        });
        AppToast.showToast(
          context: context,
          message: failure.message,
          type: ToastificationType.error,
        );
      },
      (result) {
        setState(() {
          _isSubmittingAdd = false;
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
}
