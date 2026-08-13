import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';

import '../../../rs_offers/data/models/fetch_rs_offers_products_model.dart';
import '../../../rs_offers/domain/usecases/fetch_rs_offers_products_use_case.dart';
import '../../../rs_offers/view/widget/rs_offers_product_card_widget.dart';
import '../../data/models/fetch_restaurant_details_model.dart';
import '../widgets/special_offer_card.dart';

class StoreOfferProductsScreenParams {
  const StoreOfferProductsScreenParams({required this.offer});

  final RestaurantDetailsOffer offer;
}

class RsStoreOfferProductsScreen extends StatefulWidget {
  const RsStoreOfferProductsScreen({super.key, required this.params});

  final StoreOfferProductsScreenParams params;

  @override
  State<RsStoreOfferProductsScreen> createState() =>
      _RsStoreOfferProductsScreenState();
}

class _RsStoreOfferProductsScreenState
    extends State<RsStoreOfferProductsScreen> {
  late Future<FetchRsOffersProductsModel?> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<FetchRsOffersProductsModel?> _loadProducts() async {
    final offerId = widget.params.offer.id;
    if (offerId == null || offerId <= 0) {
      return null;
    }

    final result = await getIt<FetchRsOffersProductsUseCase>()(
      FetchRsOffersProductsParams(page: 1, perPage: 100, offerId: offerId),
    );

    return result.fold((_) => null, (response) => response);
  }

  void _retry() {
    setState(() {
      _productsFuture = _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final offerName = (widget.params.offer.name ?? '').trim();

    return Scaffold(
      backgroundColor: context.onPrimary,
      appBar: AppBar(
        backgroundColor: context.onPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AppText(
          offerName.isEmpty ? 'تفاصيل العرض' : offerName,
          maxLines: 1,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<FetchRsOffersProductsModel?>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _OfferProductsLoading(offer: widget.params.offer);
          }

          final response = snapshot.data;
          if (response == null) {
            return _OfferProductsError(
              offer: widget.params.offer,
              onRetry: _retry,
            );
          }

          final products =
              response.data ?? const <FetchRsOffersProductsModelDataItem>[];
          final total = response.meta?.total ?? products.length;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: SpecialOfferCard(
                    offer: widget.params.offer,
                    width: double.infinity,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      AppText(
                        'منتجات العرض',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      AppText(
                        '$total منتج',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: AppText(
                        'لا توجد منتجات مشمولة بهذا العرض حالياً',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          RsOffersProductCardWidget(product: products[index]),
                      childCount: products.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _OfferProductsLoading extends StatelessWidget {
  const _OfferProductsLoading({required this.offer});

  final RestaurantDetailsOffer offer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        SpecialOfferCard(offer: offer, width: double.infinity),
        const SizedBox(height: 28),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _OfferProductsError extends StatelessWidget {
  const _OfferProductsError({required this.offer, required this.onRetry});

  final RestaurantDetailsOffer offer;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        SpecialOfferCard(offer: offer, width: double.infinity),
        SizedBox(height: 32),
        AppText(
          'تعذر تحميل منتجات العرض',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        AppText(
          'تحقق من الاتصال وحاول مرة أخرى.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ),
      ],
    );
  }
}
