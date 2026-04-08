import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../core/widgets/download_more.dart';
import '../../../../../core/widgets/failure_widget.dart';
import '../../../../../core/widgets/loading_list.dart';
import '../../../domain/usecases/get_compare_products_use_case.dart';
import '../../manager/bloc/sm_stores_bloc.dart';
import '../product_card_2.dart';

class RelatedProductsDialog extends StatelessWidget {
  const RelatedProductsDialog({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.fromLTRB(16, 16, 16, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFFF3F4F6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  "نتائج المقارنة",
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.pop();
                  },
                  customBorder: CircleBorder(),
                  child: Ink(
                    width: 24,
                    height: 24,
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.x,
                        size: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            BlocBuilder<SmStoresBloc, SmStoresState>(
              buildWhen: (previous, current) =>
                  previous.compareProducts != current.compareProducts,
              builder: (context, state) {
                final cp = state.compareProducts!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 400),
                      child: cp.builder(
                        loadingWidget: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: LoadingList(
                            heightCard: 120,
                            borderRadius: 24,
                            length: 4,
                          ),
                        ),
                        emptyWidget: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: AppText.labelMedium(
                              'لا توجد منتجات للمقارنة',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        successWidget: () {
                          return ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            itemBuilder: (context, index) {
                              if (cp.length <= index) {
                                if (cp.length == index) {
                                  context.read<SmStoresBloc>().add(
                                        GetCompareProductsEvent(
                                          params: GetCompareProductsParams(
                                            page: cp.pageNumber,
                                            productId: productId,
                                          ),
                                        ),
                                      );
                                }
                                return DownloadMore();
                              }
                              return ProductCard2(item: cp.list[index]);
                            },
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemCount: cp.listLength(1),
                          );
                        },
                        failedWidget: Center(
                          child: FailureWidget(
                            message: cp.errorMessage.toString(),
                            onRetry: () {
                              context.read<SmStoresBloc>().add(
                                    GetCompareProductsEvent(
                                      isReload: true,
                                      params: GetCompareProductsParams(
                                        page: 1,
                                        productId: productId,
                                      ),
                                    ),
                                  );
                            },
                          ),
                        ),
                        onTapRetry: () {
                          context.read<SmStoresBloc>().add(
                                GetCompareProductsEvent(
                                  isReload: true,
                                  params: GetCompareProductsParams(
                                    page: 1,
                                    productId: productId,
                                  ),
                                ),
                              );
                        },
                      ),
                    ),
                    if (cp.status == BlocStatus.success)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AppText(
                          '${cp.total} منتجات',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
