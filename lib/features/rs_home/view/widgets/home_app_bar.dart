import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/auth/auth_gate.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/search_field_with_voice.dart';
import '../../../profile/domain/usecases/fetch_notifications_use_case.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../../profile/view/screens/notifications_screen.dart';
import '../../../rs_main/view/rs_main_screen.dart';
import '../../../sm_cart/view/screens/sm_cart_screen.dart';

class HomeAppBar extends StatefulWidget {
  final bool isCleaning;
  final bool showSearch;
  final ProfileBloc profileBloc;

  const HomeAppBar({
    super.key,
    this.isCleaning = false,
    this.showSearch = true,
    required this.profileBloc,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  late final ProfileBloc profileBloc;
  late final CartProductsCountCubit cartProductsCountCubit;

  @override
  void initState() {
    super.initState();
    profileBloc = widget.profileBloc;
    cartProductsCountCubit = getIt<CartProductsCountCubit>();
  }

  Future<void> _openCart() async {
    await AuthGate.requireAuth(
      context,
      message: 'سجّل الدخول لعرض السلة',
      onAuthenticated: () async {
        await (widget.isCleaning
            ? context.pushRoute(
                '/cart',
                arguments: SmCartScreenParams(initialSectionIndex: 2),
              )
            : context.pushRoute(
                '/cart',
                arguments: SmCartScreenParams(initialSectionIndex: 1),
              ));

        if (mounted && !widget.isCleaning) {
          await cartProductsCountCubit.fetchCount();
        }
      },
    );
  }

  Future<void> _openNotifications() async {
    await AuthGate.requireAuth(
      context,
      message: 'سجّل الدخول لعرض الإشعارات',
      onAuthenticated: () async {
        await context.pushRoute(
          '/notifications',
          arguments: NotificationsScreenParams(profileBloc: profileBloc),
        );

        if (mounted) {
          profileBloc.add(
            FetchNotificationsEvent(
              params: FetchNotificationsParams(),
              isReload: true,
            ),
          );
        }
      },
    );
  }

  void _openSearch() {
    context.pushRoute(
      '/rsmain',
      arguments: RsMainScreenParams(
        profileBloc: profileBloc,
        initialPage: 1,
        expandSearch: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowSearch = widget.showSearch && !widget.isCleaning;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 16,
        20,
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      AuthGate.isAuthenticated
                          ? 'مرحباً بعودتك 👋'
                          : 'مرحباً بك 👋',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: UserSessionStore.userNotifier,
                      builder: (context, user, _) {
                        return Text(
                          AuthGate.isAuthenticated
                              ? UserSessionStore.displayName(user)
                              : 'زائر',
                          style: const TextStyle(
                            color: Color(0xFF1E2A78),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 28 / 18,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              BlocBuilder<CartProductsCountCubit, int>(
                bloc: cartProductsCountCubit,
                builder: (context, count) {
                  return _AppBarAction(
                    icon: FontAwesomeIcons.cartShopping,
                    badgeCount: AuthGate.isAuthenticated && !widget.isCleaning
                        ? count
                        : 0,
                    onTap: _openCart,
                  );
                },
              ),
              const SizedBox(width: 12),
              _AppBarNotificationWidget(
                profileBloc: profileBloc,
                icon: FontAwesomeIcons.bell,
                onTap: _openNotifications,
              ),
            ],
          ),
          if (shouldShowSearch) ...[
            const SizedBox(height: 16),
            SearchFieldWithVoice(
              hintText: 'ابحث عن مطعم أو وجبة...',
              onSearch: (_) => _openSearch(),
              onVoiceTap: _openSearch,
              onTap: _openSearch,
            ),
          ],
        ],
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({
    this.badgeCount = 0,
    required this.icon,
    required this.onTap,
  });

  final int badgeCount;
  final FaIconData icon;
  final void Function() onTap;

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
            child: FaIcon(
              icon,
              size: 20,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: context.onPrimaryContainer,
                    width: 2,
                  ),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppBarNotificationWidget extends StatelessWidget {
  const _AppBarNotificationWidget({
    required this.icon,
    required this.onTap,
    required this.profileBloc,
  });

  final FaIconData icon;
  final ProfileBloc profileBloc;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: profileBloc,
      buildWhen: (previous, current) =>
          previous.unreadNotification != current.unreadNotification,
      builder: (context, state) {
        return _AppBarAction(
          icon: icon,
          badgeCount: AuthGate.isAuthenticated
              ? (state.unreadNotification ?? 0)
              : 0,
          onTap: onTap,
        );
      },
    );
  }
}
