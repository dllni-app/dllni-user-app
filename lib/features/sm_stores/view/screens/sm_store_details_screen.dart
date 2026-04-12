import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../data/models/get_supermarket_store_details_model.dart';
import '../../data/models/sm_store_product_summary.dart';
import '../manager/bloc/sm_stores_bloc.dart';
import '../widgets/products_section.dart';
import '../widgets/special_offers_section.dart';
import '../widgets/store_cover_section.dart';
import '../widgets/store_address_section.dart';
import '../widgets/store_info_section.dart';
import '../widgets/store_status_section.dart';

class SmStarterStoreDetailsData {
  final String? name;
  final String? cover;
  final String? logo;
  final String? averageRating;
  final int? totalReviews;
  final double? distanceKm;
  final String? description;
  final bool? isFavorite;
  final bool? isActive;

  const SmStarterStoreDetailsData({
    this.name,
    this.cover,
    this.logo,
    this.averageRating,
    this.totalReviews,
    this.distanceKm,
    this.description,
    this.isFavorite,
    this.isActive,
  });
}

class SmStoreDetailsScreenArgs {
  final int storeId;
  final SmStarterStoreDetailsData? starter;

  const SmStoreDetailsScreenArgs({required this.storeId, this.starter});
}

double? _parseDistanceKm(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

extension SupermarketStoreDetailsStoreStarterX on SupermarketStoreDetailsStore {
  SmStarterStoreDetailsData toStarterStoreDetailsData() {
    return SmStarterStoreDetailsData(
      name: name,
      cover: cover?.toString(),
      logo: logo?.toString(),
      averageRating: averageRating,
      totalReviews: totalReviews,
      distanceKm: _parseDistanceKm(distanceKm),
      description: description,
      isFavorite: isFavorited,
      isActive: isActive,
    );
  }
}

List<String> _sortedHourLines(SupermarketStoreDetailsStore store) {
  return supermarketStoreDetailsGroupedHourLines(store.storeHours);
}

@AutoRoutePage(path: "/store")
class SmStoreDetailsScreen extends StatefulWidget {
  const SmStoreDetailsScreen({super.key, this.args});
  final SmStoreDetailsScreenArgs? args;

  @override
  State<SmStoreDetailsScreen> createState() => _SmStoreDetailsScreenState();
}

class _SmStoreDetailsScreenState extends State<SmStoreDetailsScreen> {
  SmStarterStoreDetailsData? _headerData(SmStoresState state) {
    final fromApi = state.store;
    if (fromApi != null) {
      return fromApi.toStarterStoreDetailsData();
    }
    return widget.args?.starter;
  }

  List<Widget> _productSections(SupermarketStoreDetailsStore store) {
    final products = store.products ?? [];
    if (products.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: AppText.labelMedium(
              'لا توجد منتجات',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ];
    }

    final byCategory = <int, List<SmStoreProductSummary>>{};
    for (final p in products) {
      final id = p.categoryId ?? -1;
      byCategory.putIfAbsent(id, () => []).add(p);
    }

    final categories = List<SupermarketStoreDetailsCategory>.from(
      store.categories ?? [],
    )..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

    final widgets = <Widget>[];
    final emitted = <int>{};

    for (final c in categories) {
      final id = c.id;
      if (id == null) continue;
      final list = byCategory[id];
      if (list == null || list.isEmpty) continue;
      widgets.add(ProductsSection(title: c.name ?? 'منتجات', products: list));
      emitted.add(id);
    }

    for (final entry in byCategory.entries) {
      if (entry.value.isEmpty) continue;
      if (emitted.contains(entry.key)) continue;
      String title = 'منتجات';
      if (entry.key != -1) {
        for (final c in categories) {
          if (c.id == entry.key) {
            title = c.name ?? 'منتجات';
            break;
          }
        }
      }
      widgets.add(ProductsSection(title: title, products: entry.value));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SmStoresBloc>()
        ..add(
          LoadSupermarketStoreDetailsEvent(storeId: widget.args?.storeId ?? 0),
        ),
      child: BlocBuilder<SmStoresBloc, SmStoresState>(
        builder: (context, state) {
          final header = _headerData(state);
          final store = state.store;
          final loading = state.storeDetailsStatus == BlocStatus.loading;
          final failed = state.storeDetailsStatus == BlocStatus.failed;
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  StoreCoverSection(
                    store: header,
                    storeId: widget.args?.storeId ?? 0,
                  ),
                  StoreStatusSection(store: header),
                  if (store != null) ...[
                    StoreAddressSection(
                      address: store.address,
                      phone: store.phone,
                      email: store.email,
                      distanceKm: _parseDistanceKm(store.distanceKm),
                      hourLines: _sortedHourLines(store),
                    ),
                    SizedBox(height: 16),
                    SpecialOffersSection(offers: store.offers),
                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: Text(
                              "منتجات المتجر",
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 28 / 18,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            child: Text(
                              " عرض الكل ",
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 20 / 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    ..._productSections(store),
                    SizedBox(height: 40),
                    StoreInfoSection(
                      description: store.description,
                      hours: store.storeHours ?? [],
                    ),
                  ] else if (failed && store == null)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: FailureWidget(
                        message: state.errorMessage ?? '',
                        onRetry: () {
                          context.read<SmStoresBloc>().add(
                            LoadSupermarketStoreDetailsEvent(
                              storeId: widget.args?.storeId ?? 0,
                            ),
                          );
                        },
                      ),
                    )
                  else if (loading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  SizedBox(height: 155),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
