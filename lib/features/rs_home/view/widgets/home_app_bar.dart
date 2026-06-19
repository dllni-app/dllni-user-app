import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/cart/cart_products_count_cubit.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../sm_cart/view/screens/sm_cart_screen.dart';

class HomeAppBar extends StatelessWidget {
  final bool isHome;
  HomeAppBar({super.key,this.isHome=false});

  @override
  Widget build(BuildContext context) {
    final displayName = UserSessionStore.displayName ?? 'اسم المستخدم';

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
                      "مرحباً بعودتك 👋",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                      ),
                    ),
                    Text(
                      displayName,
                      style: TextStyle(
                        color: Color(0xFF1E2A78),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 28 / 18,
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<CartProductsCountCubit, int>(
                bloc: getIt<CartProductsCountCubit>(),
                builder: (context, cartCount) {
                  return _AppBarAction(
                    badgeCount: cartCount,
                    icon: FontAwesomeIcons.cartShopping,
                    isHome: isHome,
                    onTap: () {
                      context.pushRoute(
                        "/cart",
                        arguments: SmCartScreenParams(initialSectionIndex: 1),
                      );
                    },
                  );
                },
              ),
              SizedBox(width: 12),
              _AppBarAction(
                hasNew: true,
                icon: FontAwesomeIcons.bell,
                isHome: isHome,
                onTap: () {
                  context.pushRoute("/notifications");
                },
              )
            ],
          ),
          SizedBox(height: 16),
          // SearchFieldWithVoice(onSearch: (search) {}, onVoiceTap: () {}),
        ],
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({
    this.hasNew = false,
    this.badgeCount,
    required this.icon,
    required this.onTap,
    required this.isHome,
  });

  final bool hasNew;
  final bool isHome;
  final int? badgeCount;
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
          if (badgeCount != null && isHome==false)
            Positioned(
              top: 2,
              right: 0,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: const Color(0xFFFF7A00),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else if (hasNew)
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
