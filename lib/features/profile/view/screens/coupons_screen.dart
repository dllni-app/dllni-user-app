import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/platform_coupon_models.dart';
import '../manager/coupons_cubit.dart';
import '../widgets/personal_details_app_bar.dart';
import '../widgets/platform_coupon_card.dart';

@AutoRoutePage()
class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  late final CouponsCubit _cubit;
  String _selectedSection = 'all';

  @override
  void initState() {
    super.initState();
    _cubit = getIt<CouponsCubit>()..loadCoupons();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _refreshCoupons() => _cubit.loadCoupons();

  List<PlatformCouponModel> _visibleCoupons(
    List<PlatformCouponModel> coupons,
  ) {
    return coupons
        .where((coupon) => coupon.appliesToSection(_selectedSection))
        .toList(growable: false);
  }

  void _selectSection(String section) {
    if (_selectedSection == section) return;
    setState(() => _selectedSection = section);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CouponsCubit>.value(
      value: _cubit,
      child: BlocListener<CouponsCubit, CouponsState>(
        listenWhen: (previous, current) =>
            previous.couponsStatus != current.couponsStatus &&
            current.couponsStatus == BlocStatus.failed,
        listener: (context, state) {
          if (state.errorMessage == null || state.errorMessage!.isEmpty) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                const PersonalDetailsAppBar(title: 'الكوبونات'),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      _CouponSectionFilter(
                        label: 'الكل',
                        selected: _selectedSection == 'all',
                        onSelected: () => _selectSection('all'),
                      ),
                      _CouponSectionFilter(
                        label: 'التنظيف',
                        selected: _selectedSection == 'cleaning',
                        onSelected: () => _selectSection('cleaning'),
                      ),
                      _CouponSectionFilter(
                        label: 'المطاعم',
                        selected: _selectedSection == 'restaurant',
                        onSelected: () => _selectSection('restaurant'),
                      ),
                      _CouponSectionFilter(
                        label: 'السوبر ماركت',
                        selected: _selectedSection == 'supermarket',
                        onSelected: () => _selectSection('supermarket'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: BlocBuilder<CouponsCubit, CouponsState>(
                    builder: (context, state) {
                      if (state.couponsStatus == null ||
                          state.couponsStatus == BlocStatus.loading ||
                          state.couponsStatus == BlocStatus.init) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final visibleCoupons = _visibleCoupons(state.coupons);
                      if (visibleCoupons.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _refreshCoupons,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 180),
                              Center(
                                child: Text(
                                  'لا توجد كوبونات متاحة لهذا القسم حالياً',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshCoupons,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            16,
                            0,
                            16,
                            20,
                          ),
                          itemCount: visibleCoupons.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              PlatformCouponCard(
                            coupon: visibleCoupons[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CouponSectionFilter extends StatelessWidget {
  const _CouponSectionFilter({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        selectedColor: const Color(0xffFFF7ED),
        side: BorderSide(
          color: selected
              ? const Color(0xffF97316)
              : const Color(0xffE5E7EB),
        ),
        labelStyle: TextStyle(
          color: selected
              ? const Color(0xffC2410C)
              : const Color(0xff4B5563),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
