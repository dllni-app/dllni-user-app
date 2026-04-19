import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/widgets/rs_app_product_card.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../data/models/fetch_restaurant_details_model.dart';
import '../../data/models/fetch_restaurant_products_search_model.dart';
import '../../domain/usecases/add_restaurant_cart_item_use_case.dart';
import '../../domain/usecases/fetch_restaurant_details_use_case.dart';
import '../models/product_preview_data.dart';
import '../models/store_product_item.dart';
import 'rs_product_details_screen.dart';

@AutoRoutePage(path: "/rs_store-all-products")
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

  String _resolveRestaurantName(FetchRestaurantDetailsModel? details) {
    final name = (details?.restaurant?.name ?? '').trim();
    return name.isNotEmpty ? name : 'مطعم';
  }

  List<StoreProductItem> _buildProducts(FetchRestaurantDetailsModel? details) {
    final restaurantName = _resolveRestaurantName(details);
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
          restaurantName: restaurantName,
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
        restaurantName: restaurantName,
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
        final details = snapshot.data;
        final products = _buildProducts(details);
        final restaurantName = _resolveRestaurantName(details);
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
                  separatorBuilder: (_, index) => SizedBox(width: 8),
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
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: filteredProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemBuilder: (_, index) => _AllProductsCard(product: filteredProducts[index], restaurantName: restaurantName),
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
  const _AllProductsCard({required this.product, required this.restaurantName});

  final StoreProductItem product;
  final String restaurantName;

  @override
  State<_AllProductsCard> createState() => _AllProductsCardState();
}

class _AllProductsCardState extends State<_AllProductsCard> {
  StoreProductItem get product => widget.product;

  String get restaurantName => widget.restaurantName;

  @override
  Widget build(BuildContext context) {
    final safeImage = (product.imageUrl ?? '').trim();
    final safeRestaurant = restaurantName.trim().isNotEmpty ? restaurantName.trim() : 'مطعم';
    final safeOffer = ((product.offerBadgeText ?? product.offer ?? '').trim()).isNotEmpty
        ? (product.offerBadgeText ?? product.offer ?? '').trim()
        : 'عرض';

    return RsAppProductCard(
      image: safeImage,
      productId: product.id!,
      title: product.name,
      restaurant: safeRestaurant,
      price: product.priceText,
      offer: FetchRestaurantProductsSearchModelActiveOffer(
        badgeText: product.offerBadgeText,
        discountType: product.offerDiscountType,
        discountValue: product.offerDiscountValue,
        title: product.offerUrgencyTag,
      ),
      onTap: () => context.pushRoute(
        '/rs_product',
        arguments: ProductDetailsScreenParams(product: ProductPreviewData.fromStoreProduct(product, fallbackRestaurantName: safeRestaurant)),
      ),
    );
  }
}
