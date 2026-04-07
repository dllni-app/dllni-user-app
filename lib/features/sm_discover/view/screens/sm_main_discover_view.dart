import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../../../../core/widgets/download_more.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../../core/widgets/loading_list.dart';
import '../../../../core/widgets/search_with_type_dropdown.dart';
import '../../domain/usecases/browse_stores_use_case.dart';
import '../manager/bloc/sm_discover_bloc.dart';
import '../widgets/store_card.dart';

class SmMainDiscoverView extends StatefulWidget {
  const SmMainDiscoverView({
    super.key,
    required this.onTypeSelected,
    this.expandSearch = false,
  });
  final void Function(SearchType type) onTypeSelected;
  final bool expandSearch;

  @override
  State<SmMainDiscoverView> createState() => _SmMainDiscoverViewState();
}

class _SmMainDiscoverViewState extends State<SmMainDiscoverView> {
  String _selectedSort = 'nearestBy';
  final List<String> _sortOptions = ['nearestBy', 'alphabet'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SmDiscoverBloc>()
        ..add(
          BrowseStoresEvent(
            isReload: true,
            params: BrowseStoresParams(sort: _selectedSort),
          ),
        ),
      child: Column(
        children: [
          AppSimpleAppBarWithSearch(
            title: "تصفح",
            onTypeSelected: widget.onTypeSelected,
            isSearchExpand: widget.expandSearch,
          ),
          SizedBox(height: 16),

          // DiscoverTabBar(items: discoverTabs, onChanged: (index) {}),
          // SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                BlocBuilder<SmDiscoverBloc, SmDiscoverState>(
                  buildWhen: (previous, current) =>
                      previous.browseStores != current.browseStores,
                  builder: (context, state) {
                    return Expanded(
                      child: AppText(
                        "${state.browseStores?.total ?? 0} متجر متاح",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 20 / 14,
                        ),
                      ),
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    return PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == _selectedSort) return;
                        setState(() => _selectedSort = value);
                        context.read<SmDiscoverBloc>().add(
                          BrowseStoresEvent(
                            isReload: true,
                            params: BrowseStoresParams(sort: _selectedSort),
                          ),
                        );
                      },
                      itemBuilder: (_) => _sortOptions
                          .map(
                            (option) => PopupMenuItem<String>(
                              value: option,
                              child: AppText(
                                option == "alphabet"
                                    ? "الترتيب الأبجدي"
                                    : "الأقرب إلي",
                                style: TextStyle(
                                  color: _selectedSort == option
                                      ? Color(0xFF4CAF50)
                                      : Color(0xFF6B7280),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            AppText(
                              "ترتيب حسب: ${_selectedSort == "alphabet" ? "الترتيب الأبجدي" : "الأقرب إلي"}",
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 20 / 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            FaIcon(
                              FontAwesomeIcons.angleDown,
                              size: 12,
                              color: Color(0xFF4CAF50),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 4),

          Expanded(
            child: BlocBuilder<SmDiscoverBloc, SmDiscoverState>(
              buildWhen: (previous, current) =>
                  previous.browseStores != current.browseStores,
              builder: (context, state) {
                return state.browseStores!.builder(
                  loadingWidget: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LoadingList(
                      heightCard: 279,
                      borderRadius: 24,
                      length: 5,
                    ),
                  ),
                  emptyWidget: AppText.labelMedium(
                    'لا يوجد متاجر',
                    fontWeight: FontWeight.w400,
                  ),
                  successWidget: () {
                    return ListView.separated(
                      padding: EdgeInsetsDirectional.all(20),
                      itemBuilder: (context, index) {
                        if (state.browseStores!.length <= index) {
                          if (state.browseStores!.length == index) {
                            context.read<SmDiscoverBloc>().add(
                              BrowseStoresEvent(
                                isReload: false,
                                params: BrowseStoresParams(
                                  page: state.browseStores!.pageNumber,
                                ),
                              ),
                            );
                          }
                          return DownloadMore();
                        }
                        return StoreCard(store: state.browseStores![index]);
                      },
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16),
                      itemCount: state.browseStores!.listLength(1),
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
    );
  }
}

// ListView.separated(
//             padding: EdgeInsets.all(20),
//             itemBuilder: (_, index) => StoreCard(store: stores[index]),
//             separatorBuilder: (_, _) => SizedBox(height: 16),
//             itemCount: stores.length,
//           )
