import 'dart:ui';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';
import '../../../sm_discover/domain/usecases/change_store_favorite_use_case.dart';
import '../../../sm_discover/view/manager/bloc/sm_discover_bloc.dart';
import '../screens/sm_store_details_screen.dart';

class StoreCoverSection extends StatefulWidget {
  const StoreCoverSection({super.key, this.store, this.storeId = 0});
  final SmStarterStoreDetailsData? store;
  final int storeId;

  @override
  State<StoreCoverSection> createState() => _StoreCoverSectionState();
}

class _StoreCoverSectionState extends State<StoreCoverSection> {
  late bool _isFavorite;
  late SmDiscoverBloc _bloc;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.store?.isFavorite ?? false;
    _bloc = getIt<SmDiscoverBloc>();
  }

  @override
  void didUpdateWidget(covariant StoreCoverSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.store?.isFavorite;
    final prev = oldWidget.store?.isFavorite;
    if (next != prev) {
      _isFavorite = next ?? false;
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final unknownHeader = s == null;
    final coverUrl = (s?.cover ?? '').toString().trim();
    final logoUrl = (s?.logo ?? '').toString().trim();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.pop<bool>(_isFavorite);
          });
        }
      },
      child: SizedBox(
        height: 280 + MediaQuery.paddingOf(context).top,
        child: Stack(
          children: [
            Positioned.fill(
              child: unknownHeader || coverUrl.isEmpty
                  ? ColoredBox(color: Color(0xFFE5E7EB))
                  : AppImage.network(
                      coverUrl,
                      errorWidget: Icon(Icons.error_outline),
                      fit: BoxFit.cover,
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0x99000000),
                      Color(0x33000000),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 12,
              right: 16,
              child: _ActionButton(
                icon: FontAwesomeIcons.arrowRight,
                onTap: () => context.pop<bool>(_isFavorite),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 12,
              left: 16,
              child: Row(
                children: [
                  BlocListener<SmDiscoverBloc, SmDiscoverState>(
                    bloc: _bloc,
                    listenWhen: (previous, current) =>
                        previous.changeStoreFavoriteStatus !=
                        current.changeStoreFavoriteStatus,
                    listener: (context, state) {
                      if (state.changeStoreFavoriteStatus ==
                          BlocStatus.failed) {
                        setState(() => _isFavorite = !_isFavorite);
                        AppToast.showToast(
                          context: context,
                          message: state.errorMessage.toString(),
                          type: ToastificationType.error,
                        );
                      }
                    },
                    child: Builder(
                      builder: (context) {
                        return _ActionButton(
                          icon: _isFavorite
                              ? FontAwesomeIcons.solidHeart
                              : FontAwesomeIcons.heart,
                          color: _isFavorite
                              ? Color(0xFFCF0E0E)
                              : Color(0xFF1F2937),
                          onTap: () {
                            setState(() => _isFavorite = !_isFavorite);
                            _bloc.add(
                              ChangeStoreFavoriteEvent(
                                params: ChangeStoreFavoriteParams(
                                  storeId: widget.storeId,
                                  isFavorite: _isFavorite,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  _ActionButton(
                    icon: FontAwesomeIcons.shareNodes,
                    onTap: () {},
                  ),
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
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: unknownHeader || logoUrl.isEmpty
                        ? AppImage.asset(
                            AppImages.store,
                            width: 80,
                            height: 80,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            fit: BoxFit.contain,
                            errorWidget: Icon(Icons.store_outlined),
                          )
                        : AppImage.network(
                            logoUrl,
                            errorWidget: Icon(Icons.error_outline),
                            width: 80,
                            height: 80,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            fit: BoxFit.contain,
                          ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 4, left: /*44 +*/ 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            unknownHeader
                                ? '…'
                                : (s.name?.isNotEmpty == true ? s.name! : ''),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unknownHeader
                                  ? Color(0xE6FFFFFF)
                                  : AppColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 32 / 24,
                            ),
                          ),
                          AppText(
                            unknownHeader ? '' : (s.description ?? '').trim(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Positioned(
            //   left: 16,
            //   bottom: 16,
            //   child: GestureDetector(
            //     onTap: () {},
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.all(Radius.circular(12)),
            //       child: BackdropFilter(
            //         filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            //         child: Container(
            //           width: 44,
            //           height: 44,
            //           alignment: Alignment.center,
            //           decoration: BoxDecoration(
            //             color: Color(0xE5FFFFFF),
            //             borderRadius: BorderRadius.all(Radius.circular(12)),
            //           ),
            //           child: Icon(
            //             Icons.fullscreen,
            //             size: 22,
            //             color: Color(0xFF1F2937),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap, this.color});
  final FaIconData icon;
  final Color? color;
  final void Function() onTap;

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
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: -2,
              color: Color(0x1A000000),
            ),
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -1,
              color: Color(0x1A000000),
            ),
          ],
        ),
        child: FaIcon(icon, size: 18, color: color ?? Color(0xFF1F2937)),
      ),
    );
  }
}
