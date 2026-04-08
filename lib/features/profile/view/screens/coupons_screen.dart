import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/coupons_cubit.dart';
import '../widgets/personal_details_app_bar.dart';
import '../widgets/restaurant_coupon_card.dart';

@AutoRoutePage()
class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  Future<void> _refreshCoupons() async {
    final cubit = context.read<CouponsCubit>();
    await cubit.loadCoupons();
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
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<CouponsCubit, CouponsState>(
                    builder: (context, state) {
                      if (state.couponsStatus == null || state.couponsStatus == BlocStatus.loading || state.couponsStatus == BlocStatus.init) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.coupons.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: _refreshCoupons,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 200),
                              Center(child: Text('لا توجد كوبونات متاحة حالياً')),
                            ],
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: _refreshCoupons,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
                          itemCount: state.coupons.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final coupon = state.coupons[index];
                            return RestaurantCouponCard(coupon: coupon);
                          },
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
