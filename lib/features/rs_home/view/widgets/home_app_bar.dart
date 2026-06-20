import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../sm_cart/view/screens/sm_cart_screen.dart';

class HomeAppBar extends StatelessWidget {
  final bool isHome;
  const HomeAppBar({super.key, this.isHome = false});

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
                icon: FontAwesomeIcons.cartShopping,
                onTap: () {
                  context.pushRoute(
                    '/cart',
                    arguments: SmCartScreenParams(initialSectionIndex: 1),
                  );
                },
              ),
              SizedBox(width: 12),
              _AppBarAction(
                hasNew: true,
                icon: FontAwesomeIcons.bell,
                onTap: () {
                  context.pushRoute('/notifications');
                },
              ),
            ],
          ),
          SizedBox(height: 16),
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
