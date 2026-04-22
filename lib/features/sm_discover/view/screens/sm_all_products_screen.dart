import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/widgets/app_app_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/download_more.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../../core/widgets/loading_list.dart';
import '../../domain/usecases/browse_products_use_case.dart';
import '../manager/bloc/sm_discover_bloc.dart';
import '../widgets/product_card.dart';

@AutoRoutePage(path: "/sm_store-all-products")
class SmAllProductsScreen extends StatefulWidget {
  const SmAllProductsScreen({super.key, required this.storeId});

  final int storeId;

  @override
  State<SmAllProductsScreen> createState() =>
      _SmAllProductsScreenState();
}

class _SmAllProductsScreenState extends State<SmAllProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SmDiscoverBloc>()
        ..add(
          BrowseProductsEvent(
            params: BrowseProductsParams(storeId: widget.storeId),
          ),
        ),
      child: Scaffold(
        backgroundColor: context.onPrimary,
        body: Column(
          children: [
            AppSimpleAppBar2(title: "كل المنتجات"),
            Expanded(
              child: BlocBuilder<SmDiscoverBloc, SmDiscoverState>(
                buildWhen: (previous, current) =>
                    previous.browseProducts != current.browseProducts,
                builder: (context, state) {
                  return state.browseProducts!.builder(
                    loadingWidget: Padding(
                      padding: const EdgeInsets.all(20),
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
                        'لا يوجد منتجات',
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
                          if (state.browseProducts!.length <= index) {
                            if (state.browseProducts!.length == index) {
                              context.read<SmDiscoverBloc>().add(
                                BrowseProductsEvent(
                                  isReload: false,
                                  params: BrowseProductsParams(
                                    page: state.browseProducts!.pageNumber,
                                  ),
                                ),
                              );
                            }
                            return DownloadMore();
                          }
                          return ProductCard(
                            product: state.browseProducts![index],
                          );
                        },
                        // separatorBuilder: (context, index) =>
                        //     SizedBox(height: 16),
                        itemCount: state.browseProducts!.listLength(1),
                      );
                    },
                    failedWidget: Center(
                      child: FailureWidget(
                        message: state.errorMessage.toString(),
                        onRetry: () {},
                      ),
                    ),
                    onTapRetry: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
