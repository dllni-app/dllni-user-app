import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/features/rs_home/view/manager/bloc/rs_home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/rs_app_offer_card.dart';
import 'offer_card.dart';

class ExclusiveOffersSection extends StatelessWidget {
  const ExclusiveOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              String badgeText(index) {
                final badge = list[index].offerBadgeText?.trim();
                if (badge != null && badge.isNotEmpty) return badge;
                final value = list[index].discountValue;
                if (value == null) return '';
                if (list[index].discountType == 'percentage') {
                  return 'خصم ${value.toStringAsFixed(0)}%';
                }
                return 'خصم ${value.toStringAsFixed(2)}';
              }
              return SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.symmetric(vertical: 10),
                  itemBuilder: (context, index) => RsAppOfferCard(
                    offer: badgeText(index),
                    image: list[index].imageUrl!,
                    title: list[index].restaurantName ?? list[index].products![0].name!,
                    onTap: () {},
                    subtitle: list[index].offerDescription!,
                  ),
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
