import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../manager/bloc/rs_home_bloc.dart';
import 'store_card.dart';

class NearStoresSection extends StatelessWidget {
  const NearStoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.locationDot, color: Color(0xFF6C63FF), size: 15),
            SizedBox(width: 8),
            AppText(
              "مطاعم قريبة منك",
              style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16, fontWeight: FontWeight.w700, height: 24 / 16),
            ),
          ],
        ),
        SizedBox(height: 12),
        BlocBuilder<RsHomeBloc, RsHomeState>(
          builder: (context, state) {
            if (state.restaurantNearestRestaurantsStatus == BlocStatus.loading ||
                state.restaurantNearestRestaurantsStatus == BlocStatus.init ||
                state.restaurantNearestRestaurantsStatus == null) {
              return Center(child: CircularProgressIndicator());
            } else if (state.restaurantNearestRestaurantsStatus == BlocStatus.failed) {
              return Center(child: AppText.labelLarge(state.errorMessage ?? 'حدث خطا ما'));
            } else {
              final list = state.restaurantNearestRestaurants?.nearestRestaurants ?? const [];
              return SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.symmetric(vertical: 10),
                  itemBuilder: (context, index) => StoreCard(store: list[index]),
                  separatorBuilder: (context, index) => SizedBox(width: 10),
                  itemCount: list.length,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
