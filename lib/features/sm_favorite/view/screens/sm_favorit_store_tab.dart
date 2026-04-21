import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/download_more.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../../core/widgets/loading_list.dart';
import '../../../sm_discover/view/manager/bloc/sm_discover_bloc.dart';
import '../../../sm_discover/view/widgets/store_card.dart';
import '../../domain/usecases/get_favorite_supermarket_stores_use_case.dart';
import '../manager/bloc/sm_favorite_bloc.dart';

class SmFavoriteStoreTab extends StatelessWidget {
  const SmFavoriteStoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmFavoriteBloc, SmFavoriteState>(
      buildWhen: (previous, current) =>
          previous.favoriteStores != current.favoriteStores,
      builder: (context, state) {
        return state.favoriteStores!.builder(
          loadingWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: LoadingGrid(
              heightCard: 180,
              borderRadius: 24,
              length: 6,
              crossAxisSpacing: 11,
              mainAxisSpacing: 17,
            ),
          ),
          emptyWidget: Center(
            child: AppText.labelMedium(
              'لا يوجد متاجر مفضلة',
              fontWeight: FontWeight.w400,
            ),
          ),
          successWidget: () {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 11,
                mainAxisSpacing: 17,
                mainAxisExtent: 180,
              ),
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                if (state.favoriteStores!.length <= index) {
                  if (state.favoriteStores!.length == index) {
                    context.read<SmFavoriteBloc>().add(
                      FetchFavoriteSupermarketStoresEvent(
                        params: GetFavoriteSupermarketStoresParams(
                          page: state.favoriteStores!.pageNumber,
                        ),
                      ),
                    );
                  }
                  return DownloadMore();
                }
                return BlocProvider(
                  create: (context) => getIt<SmDiscoverBloc>(),
                  child: StoreCard(store: state.favoriteStores![index]),
                );
              },
              // separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemCount: state.favoriteStores!.listLength(1),
            );
          },
          failedWidget: Center(
            child: FailureWidget(
              message: state.errorMessage.toString(),
              onRetry: () {
                context.read<SmFavoriteBloc>().add(
                  FetchFavoriteSupermarketStoresEvent(
                    isReload: true,
                    params: GetFavoriteSupermarketStoresParams(page: 1),
                  ),
                );
              },
            ),
          ),
          onTapRetry: () {
            context.read<SmFavoriteBloc>().add(
              FetchFavoriteSupermarketStoresEvent(
                isReload: true,
                params: GetFavoriteSupermarketStoresParams(page: 1),
              ),
            );
          },
        );
      },
    );
  }
}
