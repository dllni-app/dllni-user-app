import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/widgets/rs_app_product_card.dart';
import '../../../rs_discover/view/models/product_preview_data.dart';
import '../../../rs_discover/view/screens/rs_product_details_screen.dart';

import '../manager/bloc/rs_home_bloc.dart';

class SuggestedProductsSection extends StatelessWidget {
  const SuggestedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RsHomeBloc, RsHomeState>(
      builder: (context, state) {
        final status = state.restaurantSuggestedProductsStatus;
        final list = state.restaurantSuggestedProducts?.suggestedProducts ?? const [];
        if (status == BlocStatus.loading || status == null || status == BlocStatus.init) {
          return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator()));
        }
        if (status == BlocStatus.failed) {
          return const SizedBox.shrink();
        }
        if (list.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppText(
                  "مقترح لك",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF273C8F)),
                ),
                SizedBox(width: 8),
                FaIcon(FontAwesomeIcons.wandMagicSparkles, size: 16, color: context.primaryContainer),
              ],
            ),
            const SizedBox(height: 6),
            AppText(
              "اخترنا لك أفضل الأطباق بناءً على ذوقك",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF6B7280), height: 22 / 15),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 270,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  final productId = item.productId;
                  return RsAppProductCard(
                    onTap: productId == null
                        ? () {}
                        : () {
                            context.pushRoute(
                              '/rs_product',
                              arguments: ProductDetailsScreenParams(product: ProductPreviewData.fromSuggestedItem(item)),
                            );
                          },
                    productId: productId ?? 0,
                    title: item.name ?? '',
                    image: item.primaryImageUrl ?? '',
                    offer: null,
                    price: '${item.displayPrice} ل.س',
                    restaurant: item.restaurantName ?? 'restaurant',
                  );
                },
                separatorBuilder: (context, _) => const SizedBox(width: 12),
              ),
            ),
          ],
        );
      },
    );
  }
}
