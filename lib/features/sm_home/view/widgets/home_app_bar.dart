import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/search_field_with_voice.dart';
import '../../../profile/domain/usecases/fetch_notifications_use_case.dart';
import '../../../profile/view/manager/bloc/profile_bloc.dart';
import '../../../sm_main_page.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {

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
                  context.pushRoute('/cart');
                },
              ),
              SizedBox(width: 12),
              _AppBarNotificationWidget(
                profileBloc: profileBloc,
                icon: FontAwesomeIcons.bell,
                onTap: () {
                  context.pushRoute('/notifications');
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          SearchFieldWithVoice(
            onSearch: (search) {},
            onVoiceTap: () {},
            onTap: () {
              context.pushRoute(
                '/smmain',
                arguments: SmMainScreenParams(
                  initialPage: 1,
                  expandSearch: true,
                ),
              );
            },
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
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
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
