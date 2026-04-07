import 'package:flutter/material.dart';

import 'rs_offers_product_card_shimmer_widget.dart';

class RsOffersLoadingWidget extends StatelessWidget {
  const RsOffersLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) => const RsOffersProductCardShimmerWidget(),
    );
  }
}
