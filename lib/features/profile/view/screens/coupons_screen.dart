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
  String _selectedSection = 'all';

  Future<void> _refreshCoupons() async {
    await context.read<CouponsCubit>().loadCoupons();
  }

  List<PlatformCouponModel> _visibleCoupons(List<PlatformCouponModel> coupons) {
    return coupons.where((coupon) => coupon.appliesToSection(_selectedSection)).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CouponsCubit>(
      lazy: false,
      create: (_) => getIt<CouponsCubit>()..loadCoupons(),
      child: BlocListener<CouponsCubit, CouponsState>(
        listenWhen: (previous, current) => previous.couponsStatus != current.couponsStatus && current.couponsStatus == BlocStatus.failed,
        listener: (context, state) {
          if (state.errorMessage == null || state.errorMessage!.isEmpty) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
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
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      _CouponSectionFilter(value: 'all', label: 'الكل'),
                      _CouponSectionFilter(value: 'cleaning', label: 'التنظيف'),
                      _CouponSectionFilter(value: 'restaurant', label: 'المطاعم'),
                      _CouponSectionFilter(value: 'supermarket', label: 'السوبر ماركت'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: BlocBuilder<CouponsCubit, CouponsState>(
                    builder: (context, state) {
                      if (state.couponsStatus == null || state.couponsStatus == BlocStatus.loading || state.couponsStatus == BlocStatus.init) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final visibleCoupons = _visibleCoupons(state.coupons);
                      if (visibleCoupons.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _refreshCoupons,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 180),
                              Center(child: Text('لا توجد كوبونات متاحة لهذا القسم حالياً')),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshCoupons,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
                          itemCount: visibleCoupons.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => PlatformCouponCard(coupon: visibleCoupons[index]),
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
  const _CouponSectionFilter({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final page = context.findAncestorStateOfType<_CouponsScreenState>();
    final selected = page?._selectedSection == value;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => page?.setState(() => page._selectedSection = value),
        showCheckmark: false,
        selectedColor: const Color(0xffFFF7ED),
        side: BorderSide(color: selected ? const Color(0xffF97316) : const Color(0xffE5E7EB)),
        labelStyle: TextStyle(color: selected ? const Color(0xffC2410C) : const Color(0xff4B5563), fontWeight: FontWeight.w600),
      ),
    );
  }
}
