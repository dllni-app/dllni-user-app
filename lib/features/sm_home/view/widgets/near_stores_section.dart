import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/failure_widget.dart';
import '../../../../core/widgets/loading_list.dart';
import '../../domain/usecases/get_nearby_stores_use_case.dart';
import '../manager/bloc/sm_home_bloc.dart';
import 'store_card.dart';

class NearStoresSection extends StatelessWidget {
  const NearStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.locationDot,
                color: Color(0xFF6C63FF),
                size: 15,
              ),
              SizedBox(width: 8),
              AppText(
                "متاجر قريبة منك",
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          BlocBuilder<SmHomeBloc, SmHomeState>(
            buildWhen: (previous, current) =>
                previous.nearbyStoresStatus != current.nearbyStoresStatus,
            builder: (context, state) {
              if (state.nearbyStoresStatus == BlocStatus.loading) {
                return LoadingGrid(
                  heightCard: 180,
                  borderRadius: 24,
                  crossAxisSpacing: 11,
                  mainAxisSpacing: 17,
                  length: 6,
                );
              } else if (state.nearbyStoresStatus == BlocStatus.failed) {
                return FailureWidget(
                  message: state.errorMessage.toString(),
                  onRetry: () {
                    context.read<SmHomeBloc>().add(
                      GetNearbyStoresEvent(params: GetNearbyStoresParams()),
                    );
                  },
                );
              } else if (state.nearbyStoresStatus == BlocStatus.success) {
                return state.nearbyStores!.stores!.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: AppText.labelMedium(
                            'لا يوجد متاجر قريبة منك',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 11,
                          crossAxisSpacing: 17,
                          mainAxisExtent: 180,
                        ),
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (_, index) => StoreCard(
                          store: state.nearbyStores!.stores![index],
                        ),
                        // separatorBuilder: (_, _) => SizedBox(height: 12),
                        itemCount: state.nearbyStores!.stores!.length,
                      );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
