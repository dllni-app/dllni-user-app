import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/auth/auth_gate.dart';
import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/search_field_with_voice.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../../profile/view/screens/notifications_screen.dart';
import '../../../rs_main/view/rs_main_screen.dart';
import '../../../sm_cart/view/screens/sm_cart_screen.dart';

class HomeAppBar extends StatefulWidget {
  final bool isCleaning;
  final ProfileBloc profileBloc;

  const HomeAppBar({
    super.key,
    this.isCleaning = false,
    required this.profileBloc,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  late final ProfileBloc profileBloc;

  @override
  void initState() {
    profileBloc = widget.profileBloc;
    super.initState();
  }

  Future<void> _openCart() async {
    await AuthGate.requireAuth(
      context,
      message: 'سجّل الدخول لعرض السلة',
      onAuthenticated: () {
        widget.isCleaning
            ? context.pushRoute(
                '/cart',
                arguments: SmCartScreenParams(initialSectionIndex: 2),
              )
            : context.pushRoute(
                '/cart',
                arguments: SmCartScreenParams(initialSectionIndex: 1),
              );
      },
    );
  }

  Future<void> _openNotifications() async {
    await AuthGate.requireAuth(
      context,
      message: 'سجّل الدخول لعرض الإشعارات',
      onAuthenticated: () {
        context.pushRoute(
          '/notifications',
          arguments: NotificationsScreenParams(profileBloc: profileBloc),
        );
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
              _AppBarAction(
                icon: FontAwesomeIcons.cartShopping,
                onTap: _openCart,
              ),
              const SizedBox(width: 12),
              _AppBarNotificationWidget(
                profileBloc: profileBloc,
                icon: FontAwesomeIcons.bell,
                onTap: _openNotifications,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SearchFieldWithVoice(
            hintText: 'ابحث عن مطعم أو وجبة...',
            onSearch: (_) => _openSearch(),
            onVoiceTap: _openSearch,
            onTap: _openSearch,
          ),
        ],
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({
    this.hasNew = false,
    required this.icon,
    required this.onTap,
  });

  final bool hasNew;
  final FaIconData icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Stack(
        fit: StackFit.loose,
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
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        bloc: profileBloc,
        builder: (context, state) {
          return Stack(
            fit: StackFit.loose,
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
              if (AuthGate.isAuthenticated &&
                  state.unreadNotification != null &&
                  state.unreadNotification! > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.onPrimaryContainer,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      state.unreadNotification.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
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
