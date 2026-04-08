import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../sm_stores/view/screens/sm_store_details_screen.dart';
import '../../data/models/browse_stores_model.dart';
import '../../domain/usecases/change_store_favorite_use_case.dart';
import '../manager/bloc/sm_discover_bloc.dart';

class StoreData {
  final String image;
  final String name;
  final String description;
  final double rating;
  final double distance;
  final String deliveryPrice;
  final String time;
  final int discount;
  final bool isFavorite;

  StoreData({
    required this.image,
    required this.name,
    required this.description,
    required this.rating,
    required this.distance,
    required this.deliveryPrice,
    required this.time,
    required this.discount,
    this.isFavorite = false,
  });
}

class StoreCard extends StatefulWidget {
  const StoreCard({super.key, required this.store});
  final BrowseStoresModelDataItem store;

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  late bool isFavorite;

  @override
  void initState() {
    isFavorite = widget.store.isFavorited ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final s = widget.store;
        final result = await context.pushRoute(
          "/store",
          arguments: SmStoreDetailsScreenArgs(
            storeId: s.id ?? 0,
            starter: SmStarterStoreDetailsData(
              name: s.name,
              cover: s.cover,
              logo: s.logo,
              averageRating: s.averageRating?.toString(),
              totalReviews: s.totalReviews,
              distanceKm: s.distanceKm?.toDouble(),
              description: s.description,
              isFavorite: s.isFavorited,
              isActive: s.isActive,
            ),
          ),
        );
        if (result != null && result is bool) {
          isFavorite = result;
          widget.store.isFavorited = isFavorite;
          setState(() {});
        }
      },
      borderRadius: BorderRadius.all(Radius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: Color(0xFFF3F4F6)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              fit: StackFit.loose,
              children: [
                AppImage.network(
                  widget.store.cover.toString(),
                  errorWidget: Icon(Icons.error_outline),
                  height: 160,
                  width: context.width,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: BlocProvider(
                    create: (context) => getIt<SmDiscoverBloc>(),
                    child: BlocListener<SmDiscoverBloc, SmDiscoverState>(
                      listenWhen: (previous, current) =>
                          previous.changeStoreFavoriteStatus !=
                          current.changeStoreFavoriteStatus,
                      listener: (context, state) {
                        if (state.changeStoreFavoriteStatus ==
                            BlocStatus.failed) {
                          isFavorite = !isFavorite;
                          setState(() {});
                          AppToast.showToast(
                            context: context,
                            message: state.errorMessage.toString(),
                            type: ToastificationType.error,
                          );
                        }
                      },
                      child: InkWell(
                        onTap: () {
                          isFavorite = !isFavorite;
                          setState(() {});
                          context.read<SmDiscoverBloc>().add(
                            ChangeStoreFavoriteEvent(
                              params: ChangeStoreFavoriteParams(
                                storeId: widget.store.id ?? 0,
                                isFavorite: isFavorite,
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.white,
                          child: FaIcon(
                            isFavorite
                                ? FontAwesomeIcons.solidHeart
                                : FontAwesomeIcons.heart,
                            size: 16,
                            color: isFavorite
                                ? Colors.red
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.store.highestOffer != null)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.tag,
                            size: 10,
                            color: AppColors.white,
                          ),
                          SizedBox(width: 4),
                          AppText(
                            "خصم ${widget.store.highestOffer}%",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 16 / 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Positioned(
                //   bottom: 12,
                //   right: 12,
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     decoration: BoxDecoration(
                //       color: AppColors.white,
                //       borderRadius: BorderRadius.all(Radius.circular(8)),
                //     ),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         AppText(
                //           "widget.store.time",
                //           style: TextStyle(
                //             color: Color(0xFF1A1A1A),
                //             fontSize: 12,
                //             fontWeight: FontWeight.w700,
                //             height: 16 / 12,
                //           ),
                //         ),
                //         SizedBox(width: 4),
                //         FaIcon(
                //           FontAwesomeIcons.motorcycle,
                //           size: 15,
                //           color: Color(0xFF6C63FF),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppText(
                          widget.store.name.toString(),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 24 / 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              widget.store.averageRating.toString(),
                              style: TextStyle(
                                color: Color(0xFF15803D),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 16 / 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            FaIcon(
                              FontAwesomeIcons.solidStar,
                              size: 12,
                              color: Color(0xFF22C55E),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  AppText(
                    widget.store.description.toString(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.locationArrow,
                        size: 12,
                        color: Color(0xB26C63FF),
                      ),
                      SizedBox(width: 8),
                      AppText(
                        widget.store.distanceKm == null
                            ? "—"
                            : "${widget.store.distanceKm} كم",
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          height: 16 / 12,
                        ),
                      ),
                      // SizedBox(width: 8),
                      // CircleAvatar(radius: 2, backgroundColor: Color(0xFFD1D5DB)),
                      // SizedBox(width: 8),
                      // AppText(
                      //   "توصيل 15 ل.س",
                      //   style: TextStyle(
                      //     color: Color(0xFF6B7280),
                      //     fontSize: 12,
                      //     height: 16 / 12,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
