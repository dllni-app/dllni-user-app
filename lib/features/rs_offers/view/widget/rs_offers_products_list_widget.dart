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
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => RsOffersProductCardWidget(product: products.list[index]),
                  childCount: products.list.length,
                ),
              ),
            ),
            if (showFooter)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 4))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
