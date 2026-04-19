import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/bloc/rs_offers_bloc.dart';
import 'rs_offers_app_bar.dart';
import 'rs_offers_empty_widget.dart';
import 'rs_offers_error_widget.dart';
import 'rs_offers_products_list_widget.dart';

class RsOffersView extends StatelessWidget {
  const RsOffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          const RsOffersAppBar(),
          const SizedBox(height: 14),
          Expanded(
            child: BlocBuilder<RsOffersBloc, RsOffersState>(
              builder: (context, state) {
                final pagination = state.products;
                if (pagination.isFailed) {
                  return RsOffersErrorWidget(
                    message: pagination.errorMessage,
                    onRetry: () {
                      context.read<RsOffersBloc>().add(FetchRsOffersProductsEvent(isReload: true));
                    },
                  );
                }
                if (pagination.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (pagination.isEmpty) {
                  return const RsOffersEmptyWidget();
                }
                return RsOffersProductsListWidget(products: pagination);
              },
            ),
          ),
        ],
      ),
    );
  }
}
