import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../profile/domain/usecases/fetch_notifications_use_case.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../../profile/view/screens/notifications_screen.dart';
import '../../../sm_cart/view/screens/sm_cart_screen.dart';

class ClHomeAppBar extends StatefulWidget {
  const ClHomeAppBar({super.key});

  @override
  State<ClHomeAppBar> createState() => _ClHomeAppBarState();
}

class _ClHomeAppBarState extends State<ClHomeAppBar> {
  late final ProfileBloc profileBloc;

  @override
  void initState() {
    profileBloc = getIt<ProfileBloc>()
      ..add(
        FetchNotificationsEvent(
          params: FetchNotificationsParams(),
          isReload: true,
        ),
      );
    super.initState();
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
        border: Border.all(color: Color(0xFFF3F4F6)),
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
                      'مرحباً بعودتك 👋',
                      style: TextStyle(
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
                          UserSessionStore.displayName(user),
                          style: TextStyle(
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
                hasNew: false,
                icon: FontAwesomeIcons.cartShopping,
                onTap: () {
                  context.pushRoute(
                    '/cart',
                    arguments: SmCartScreenParams(initialSectionIndex: 2),
                  );
                },
              ),
              SizedBox(width: 12),
              _AppBarNotificationWidget(
                profileBloc: profileBloc,
                icon: FontAwesomeIcons.bell,
                onTap: () {
                  context.pushRoute(
                    '/notifications',
                    arguments: NotificationsScreenParams(
                      profileBloc: profileBloc,
                    ),
                  );
                },
              ),
            ],
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
      customBorder: CircleBorder(),
      child: Stack(
        fit: StackFit.loose,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFF9FAFB),
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFF3F4F6)),
            ),
            child: FaIcon(icon, size: 20, color: Color(0xFF1A1A1A)),
          ),
          if (hasNew)
            Positioned(
              top: 10,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.onPrimaryContainer,
                    width: 2,
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
    return InkWell(
      onTap: onTap,
      customBorder: CircleBorder(),
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
                  color: Color(0xFFF9FAFB),
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFF3F4F6)),
                ),
                child: FaIcon(icon, size: 20, color: Color(0xFF1A1A1A)),
              ),
              if (state.unreadNotification != null &&
                  state.unreadNotification! > 0)
                Positioned(
                  top: -2,
                  right: -2,

                  child: Container(
                    padding: EdgeInsets.all(4),
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
                      style: TextStyle(
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
