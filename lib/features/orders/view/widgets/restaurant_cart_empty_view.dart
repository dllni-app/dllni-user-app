import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../../rs_main/view/rs_main_screen.dart';
import '../../../sm_main_page.dart';

class RestaurantCartEmptyView extends StatelessWidget {
  const RestaurantCartEmptyView({
    super.key,
    required this.onRefresh,
    required this.isStore,
  });
  final bool isStore;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * .12),
          Icon(
            Icons.shopping_cart_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          AppText.titleMedium(
            'قائمة المشتريات',
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E2A78),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText.bodyMedium(
            'تصفح المطاعم وأضف المنتجات إلى سلتك من هنا.',
            color: const Color(0xFF6B7280),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Center(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E2A78),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => isStore
                  ? context.pushRoute(
                      '/smmain',
                      arguments: SmMainScreenParams(
                        initialPage: 0,
                        expandSearch: false,
                      ),
                    )
                  : context.pushRoute('/rsmain',arguments: RsMainScreenParams(
                profileBloc: getIt<ProfileBloc>(),

              )
              ),
              child: AppText.labelLarge(
                'تصفح ${isStore ? "المتاجر" : "المطاعم"}',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
