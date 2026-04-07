import 'package:flutter/material.dart';

import '../../../rs_favourite/view/widgets/favourite_empty_state.dart';

class RsOffersEmptyWidget extends StatelessWidget {
  const RsOffersEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: FavouriteEmptyState(
        title: 'لا توجد وجبات عروض حالياً',
        subtitle: 'ستظهر الوجبات التي عليها عروض هنا عند توفرها.',
      ),
    );
  }
}
