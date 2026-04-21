import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../sm_discover/view/manager/bloc/sm_discover_bloc.dart';
import '../../../sm_discover/view/widgets/product_card.dart';
import '../../../../core/widgets/download_more.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../../core/widgets/loading_list.dart';
import '../../../sm_stores/view/screens/sm_product_details_screen.dart';
import '../../domain/usecases/get_favorite_supermarket_products_use_case.dart';
import '../manager/bloc/sm_favorite_bloc.dart';

class SmFavoriteProductsTab extends StatelessWidget {
  const SmFavoriteProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmFavoriteBloc, SmFavoriteState>(
      buildWhen: (previous, current) =>
          previous.favoriteProducts != current.favoriteProducts,
      builder: (context, state) {
        return state.favoriteProducts!.builder(
          loadingWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: LoadingGrid(
              heightCard: 232,
              borderRadius: 24,
              length: 10,
              crossAxisSpacing: 7,
              mainAxisSpacing: 12,
            ),
          ),
          emptyWidget: Center(
            child: AppText.labelMedium(
              'لا يوجد منتجات مفضلة حالياً',
              fontWeight: FontWeight.w400,
            ),
          ),
          successWidget: () {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 7,
                mainAxisSpacing: 12,
                mainAxisExtent: 232,
              ),
              padding: EdgeInsetsDirectional.all(20),
              itemBuilder: (context, index) {
                if (state.favoriteProducts!.length <= index) {
                  if (state.favoriteProducts!.length == index) {
                    context.read<SmFavoriteBloc>().add(
                      FetchFavoriteSupermarketProductsEvent(
                        params: GetFavoriteSupermarketProductsParams(
                          page: state.favoriteProducts!.pageNumber,
                        ),
                      ),
                    );
                  }
                  return DownloadMore();
                }
                return BlocProvider(
                  create: (context) => getIt<SmDiscoverBloc>(),
                  child: ProductCard(product: state.favoriteProducts![index]),
                );
              },
              itemCount: state.favoriteProducts!.listLength(1),
            );
          },
          failedWidget: Center(
            child: FailureWidget(
              message: state.errorMessage.toString(),
              onRetry: () {
                context.read<SmFavoriteBloc>().add(
                  FetchFavoriteSupermarketProductsEvent(
                    isReload: true,
                    params: GetFavoriteSupermarketProductsParams(page: 1),
                  ),
                );
              },
            ),
          ),
          onTapRetry: () {
            context.read<SmFavoriteBloc>().add(
              FetchFavoriteSupermarketProductsEvent(
                isReload: true,
                params: GetFavoriteSupermarketProductsParams(page: 1),
              ),
            );
          },
        );
      },
    );
  }
}
