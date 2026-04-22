import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoreCoverSection extends StatelessWidget {
  const StoreCoverSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.coverImageUrl,
    this.logoImageUrl,
    required this.isFavorited,
    required this.onFavouriteTap,
    this.cartCount = 0,
    this.onCartTap,
    this.onShareTap,
  });

  final String title;
  final String subtitle;
  final String? coverImageUrl;
  final String? logoImageUrl;
  final bool isFavorited;
  final VoidCallback onFavouriteTap;
  final int cartCount;
  final VoidCallback? onCartTap;
  final VoidCallback? onShareTap;

  @override
  Widget build(BuildContext context) {
    final hasNetworkCover = coverImageUrl != null && (coverImageUrl!.startsWith('http://') || coverImageUrl!.startsWith('https://'));
    final hasAssetCover = coverImageUrl != null && coverImageUrl!.isNotEmpty && !hasNetworkCover;
    final hasNetworkLogo = logoImageUrl != null && (logoImageUrl!.startsWith('http://') || logoImageUrl!.startsWith('https://'));
    final hasAssetLogo = logoImageUrl != null && logoImageUrl!.isNotEmpty && !hasNetworkLogo;

    return SizedBox(
      height: 280 + MediaQuery.paddingOf(context).top,
      child: Stack(
        children: [
          Positioned.fill(
            child: hasNetworkCover
                ? AppImage.network(
                    coverImageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: _imagePlaceholder(),
                  )
                : hasAssetCover
                ? AppImage.asset(coverImageUrl!, fit: BoxFit.cover)
                : _imagePlaceholder(),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0x99000000), Color(0x33000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            right: 16,
            child: _ActionButton(icon: FontAwesomeIcons.arrowRight, onTap: () => context.pop()),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 16,
            child: Row(
              children: [
                _ActionButton(
                  icon: isFavorited ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  iconColor: isFavorited ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                  onTap: onFavouriteTap,
                ),
                SizedBox(width: 8),
                _CartActionButton(
                  cartCount: cartCount,
                  onTap: onCartTap ?? () {},
                ),
                SizedBox(width: 8),
                _ActionButton(icon: FontAwesomeIcons.shareNodes, onTap: onShareTap ?? () {}),
              ],
            ),
          ),
          Positioned(
            right: 16,
            left: 16,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: context.onPrimary, borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: hasNetworkLogo
                      ? AppImage.network(
                          logoImageUrl!,
                          fit: BoxFit.contain,
                          errorWidget: _imagePlaceholder(iconSize: 28),
                        )
                      : hasAssetLogo
                      ? AppImage.asset(logoImageUrl!, fit: BoxFit.contain)
                      : _imagePlaceholder(iconSize: 28),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          title,
                          style: TextStyle(color: context.onPrimary, fontSize: 24, fontWeight: FontWeight.w700),
                          scrollText: true,
                        ),
                        if (subtitle.isNotEmpty)
                          AppText(
                            subtitle,
                            scrollText: true,
                            style: TextStyle(color: context.onPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _imagePlaceholder({double iconSize = 56}) {
  return Container(
    color: const Color(0xFFF5F5F5),
    alignment: Alignment.center,
    child: Icon(
      Icons.image_outlined,
      size: iconSize,
      color: const Color(0xFF9CA3AF),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor = const Color(0xFF1F2937),
  });

  final FaIconData icon;
  final void Function() onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.onPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2, color: Color(0x1A000000)),
            BoxShadow(offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1, color: Color(0x1A000000)),
          ],
        ),
        child: FaIcon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

class _CartActionButton extends StatelessWidget {
  const _CartActionButton({
    required this.cartCount,
    required this.onTap,
  });

  final int cartCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.onPrimary,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2, color: Color(0x1A000000)),
                BoxShadow(offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1, color: Color(0x1A000000)),
              ],
            ),
            child: const FaIcon(FontAwesomeIcons.cartShopping, size: 16, color: Color(0xFF1F2937)),
          ),
          PositionedDirectional(
            top: -2,
            end: -2,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: const Color(0xFFFF7A00),
              child: AppText(
                '$cartCount',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
