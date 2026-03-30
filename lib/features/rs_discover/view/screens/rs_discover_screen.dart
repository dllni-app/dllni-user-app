import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_discover/view/screens/rs_restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../manager/bloc/rs_discover_bloc.dart';
import '../widgets/rs_discover_header.dart';
import '../widgets/rs_discover_restaurant_card.dart';

class RsDiscoverScreen extends StatelessWidget {
  const RsDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<RsDiscoverBloc>(), child: const _RsDiscoverView());
  }
}

class _RsDiscoverView extends StatelessWidget {
  const _RsDiscoverView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            const RsDiscoverHeader(),
            Expanded(
              child: BlocBuilder<RsDiscoverBloc, RsDiscoverState>(
                builder: (context, state) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                          child: _SearchAndFiltersSection(state: state),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 18, 16, 24),
                        sliver: SliverList.separated(
                          itemCount: state.visibleRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = state.visibleRestaurants[index];
                            return RsDiscoverRestaurantCard(
                              restaurant: restaurant,
                              onTap: () {
                                context.pushRoute(
                                  '/rsrestaurantdetail',
                                  arguments: RsRestaurantDetailParams(
                                    id: restaurant.id,
                                    name: restaurant.name,
                                    categoryLabel: restaurant.categoryLabel,
                                    heroImageUrl: restaurant.heroImageUrl,
                                    rating: restaurant.rating,
                                    reviewCountLabel: restaurant.reviewCountLabel,
                                    deliveryTimeLabel: restaurant.deliveryTimeLabel,
                                    deliveryFeeLabel: restaurant.deliveryFeeLabel,
                                    distanceLabel: restaurant.distanceLabel,
                                    discountLabel: restaurant.discountLabel,
                                    badgeLabel: restaurant.badgeLabel,
                                    isOpen: restaurant.isOpen,
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAndFiltersSection extends StatelessWidget {
  const _SearchAndFiltersSection({required this.state});

  final RsDiscoverState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'ابحث عن مطعم أو نوع مطبخ...',
                  hintStyle: const TextStyle(color: Color(0xff9CA3AF), fontSize: 13, fontWeight: FontWeight.w400),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xff9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xffF9FAFB),
                  contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: context.primary, width: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            DecoratedBox(
              decoration: BoxDecoration(color: context.primary, shape: BoxShape.circle),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.tune_rounded, color: context.onPrimary, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              state.filterOptions.length,
              (index) => Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: _FilterChipWidget(
                  option: state.filterOptions[index],
                  isSelected: state.selectedFilterIndex == index,
                  onTap: () {
                    context.read<RsDiscoverBloc>().add(RsDiscoverFilterChanged(index));
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            AppText.titleSmall('${state.visibleRestaurants.length} مطعم متاح', fontWeight: FontWeight.w700, color: const Color(0xff374151)),
            const Spacer(),
            PopupMenuButton<RsDiscoverSort>(
              onSelected: (value) {
                context.read<RsDiscoverBloc>().add(RsDiscoverSortChanged(value));
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: RsDiscoverSort.nearest, child: Text('الأقرب')),
                PopupMenuItem(value: RsDiscoverSort.highestRated, child: Text('الأعلى تقييماً')),
                PopupMenuItem(value: RsDiscoverSort.fastestDelivery, child: Text('التسليم الأسرع')),
              ],
              child: Row(
                children: [
                  AppText.labelLarge('ترتيب حسب: ${_sortLabel(state.selectedSort)}', color: const Color(0xff10B981), fontWeight: FontWeight.w700),
                  const SizedBox(width: 3),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xff10B981)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _sortLabel(RsDiscoverSort sort) {
    switch (sort) {
      case RsDiscoverSort.highestRated:
        return 'الأعلى تقييماً';
      case RsDiscoverSort.fastestDelivery:
        return 'التسليم الأسرع';
      case RsDiscoverSort.nearest:
        return 'الأقرب';
    }
  }
}

class _FilterChipWidget extends StatelessWidget {
  const _FilterChipWidget({required this.option, required this.isSelected, required this.onTap});

  final RsDiscoverFilterOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 8),
        decoration: BoxDecoration(
          color: isSelected ? context.primary : context.onPrimary,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: isSelected ? context.primary : const Color(0xffE5E7EB)),
        ),
        child: Row(
          children: [
            AppText.labelLarge(option.label, color: isSelected ? context.onPrimary : const Color(0xff4B5563), fontWeight: FontWeight.w700),
            const SizedBox(width: 6),
            Icon(option.icon, size: 16, color: isSelected ? context.onPrimary : const Color(0xff9CA3AF)),
          ],
        ),
      ),
    );
  }
}
