import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common_package/common_package.dart';

import '../../data/models/fetch_rs_offers_products_model.dart';
import '../manager/bloc/rs_offers_bloc.dart';
import 'rs_offers_product_card_widget.dart';

class RsOffersProductsListWidget extends StatelessWidget {
  final PaginationStateModel<FetchRsOffersProductsModelDataItem> products;

  const RsOffersProductsListWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final showFooter = !products.isEndPage && products.status == BlocStatus.loading && products.list.isNotEmpty;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 240) {
            final bloc = context.read<RsOffersBloc>();
            final state = bloc.state.products;
            if (state.isEndPage || state.status == BlocStatus.loading) {
              return false;
            }
            bloc.add(FetchRsOffersProductsEvent(loadMore: true));
          }
        }
        return false;
      },
      child: RefreshIndicator(
        color: context.primary,
        backgroundColor: context.onPrimary,
        onRefresh: () async {
          context.read<RsOffersBloc>().add(FetchRsOffersProductsEvent(isReload: true));
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          itemCount: products.list.length + (showFooter ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= products.list.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 4))),
              );
            }

            return RsOffersProductCardWidget(product: products.list[index]);
          },
          separatorBuilder: (_, _) => const SizedBox(height: 12),
        ),
      ),
    );
  }
}
