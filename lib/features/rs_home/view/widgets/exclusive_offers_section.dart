import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_home/view/manager/bloc/rs_home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'offer_card.dart';

class ExclusiveOffersSection extends StatelessWidget {
  const ExclusiveOffersSection({super.key});

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
              AppText(
                "عروض حصرية بالقرب منك",
                style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16, fontWeight: FontWeight.w700, height: 24 / 16),
              ),
              SizedBox(width: 8),
              FaIcon(FontAwesomeIcons.fire, color: context.primaryContainer, size: 14),
            ],
          ),
          BlocBuilder<RsHomeBloc, RsHomeState>(
            builder: (context, state) {
              if (state.restaurantExclusiveOffersStatus == BlocStatus.loading ||
                  state.restaurantExclusiveOffersStatus == BlocStatus.init ||
                  state.restaurantExclusiveOffersStatus == null) {
                return Center(child: CircularProgressIndicator());
              } else if (state.restaurantExclusiveOffersStatus == BlocStatus.failed) {
                return Center(child: AppText.labelLarge(state.errorMessage ?? 'حدث خطا ما'));
              } else {
                final list = state.restaurantExclusiveOffers?.exclusiveOffers ?? const [];
                return ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsetsDirectional.symmetric(vertical: 10),
                  itemBuilder: (context, index) => OfferCard(data: list[index]),
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemCount: list.length,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
