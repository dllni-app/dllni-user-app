import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/download_more.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../../core/widgets/loading_list.dart';
import '../../../../core/widgets/search_field_with_voice.dart';
import '../../../../core/widgets/search_with_type_dropdown.dart';
import '../../domain/usecases/browse_products_use_case.dart';
import '../../domain/usecases/browse_stores_use_case.dart';
import '../manager/bloc/sm_discover_bloc.dart';
import '../widgets/discover_tab_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/store_card.dart';

class SmSearchView extends StatefulWidget {
  const SmSearchView({super.key, required this.type});
  final SearchType type;

  @override
  State<SmSearchView> createState() => _SmSearchViewState();
}

class _SmSearchViewState extends State<SmSearchView> {
  late List<String> searchHistory;
  late TextEditingController searchController;
  bool isSearching = false;
  @override
  void initState() {
    searchController = TextEditingController();
    searchHistory =
        SharedPreferencesHelper.sharedPreferences!.getStringList(
          Constants.searchKey,
        ) ??
        [];
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SmSearchView oldWidget) {
    if (isSearching == true) {
      searchController.clear();
      isSearching = false;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SmDiscoverBloc>(),
      // ..add(
      //   widget.type == SearchType.store
      //       ? BrowseStoresEvent(isReload: true, params: BrowseStoresParams())
      //       : BrowseProductsEvent(
      //           isReload: true,
      //           params: BrowseProductsParams(),
      //         ),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24 + MediaQuery.paddingOf(context).top),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Builder(
              builder: (context) {
                return SearchFieldWithVoice(
                  backgroundColor: Color(0xFFF9FAFB),
                  controller: searchController,
                  hintText: widget.type == SearchType.product
                      ? "ابحث عن منتج..."
                      : "ابحث عن متجر...",
                  onVoiceTap: () {},
                  onSearch: (search) {
                    if (search.trim().isEmpty) return;
                    search = search.trim();
                    makeSearch(context, search);
                    searchHistory.removeWhere((word) => word == search);
                    searchHistory.insert(0, search);
                    setState(() {});
                    SharedPreferencesHelper.sharedPreferences!.setStringList(
                      Constants.searchKey,
                      searchHistory,
                    );
                  },
                );
              },
            ),
          ),
          if (isSearching)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: AppText(
                      "نتائج البحث",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 26 / 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: widget.type == SearchType.product
                        ? BlocBuilder<SmDiscoverBloc, SmDiscoverState>(
                            buildWhen: (previous, current) =>
                                previous.browseProducts !=
                                current.browseProducts,
                            builder: (context, state) {
                              return state.browseProducts!.builder(
                                loadingWidget: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: LoadingList(
                                    heightCard: 279,
                                    borderRadius: 24,
                                    length: 5,
                                  ),
                                ),
                                emptyWidget: Center(
                                  child: AppText.labelMedium(
                                    'لا يوجد منتجات',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                successWidget: () {
                                  return ListView.separated(
                                    padding: EdgeInsetsDirectional.all(20),
                                    itemBuilder: (context, index) {
                                      if (state.browseProducts!.length <=
                                          index) {
                                        if (state.browseProducts!.length ==
                                            index) {
                                          context.read<SmDiscoverBloc>().add(
                                            BrowseProductsEvent(
                                              isReload: false,
                                              params: BrowseProductsParams(
                                                page: state
                                                    .browseProducts!
                                                    .pageNumber,
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
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: 16),
                                    itemCount: state.browseProducts!.listLength(
                                      1,
                                    ),
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
                          )
                        : BlocBuilder<SmDiscoverBloc, SmDiscoverState>(
                            buildWhen: (previous, current) =>
                                previous.browseStores != current.browseStores,
                            builder: (context, state) {
                              return state.browseStores!.builder(
                                loadingWidget: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: LoadingList(
                                    heightCard: 279,
                                    borderRadius: 24,
                                    length: 5,
                                  ),
                                ),
                                emptyWidget: Center(
                                  child: AppText.labelMedium(
                                    'لا يوجد متاجر',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                successWidget: () {
                                  return ListView.separated(
                                    padding: EdgeInsetsDirectional.all(20),
                                    itemBuilder: (context, index) {
                                      if (state.browseStores!.length <= index) {
                                        if (state.browseStores!.length ==
                                            index) {
                                          context.read<SmDiscoverBloc>().add(
                                            BrowseStoresEvent(
                                              isReload: false,
                                              params: BrowseStoresParams(
                                                page: state
                                                    .browseStores!
                                                    .pageNumber,
                                              ),
                                            ),
                                          );
                                        }
                                        return DownloadMore();
                                      }
                                      return StoreCard(
                                        store: state.browseStores![index],
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: 16),
                                    itemCount: state.browseStores!.listLength(
                                      1,
                                    ),
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
            )
          else
            Builder(
              builder: (context) {
                return Column(
                  children: [
                    SizedBox(height: 24),
                    SearchesGroup(
                      title: "الأكثر بحثاً من قبل المستخدمين",
                      searches: [
                        "لبن المراعي",
                        "أندومي",
                        "حليب مكثف",
                        "حليب هوى الشام",
                        "طحين كاتو",
                        "رز كبسة",
                      ],
                      onSearchTap: (search) {
                        print(search);
                        makeSearch(context, search);
                      },
                    ),
                    SizedBox(height: 16),
                    Divider(height: 1, color: Color(0xFFDBDCDE)),
                    SizedBox(height: 16),
                    SearchesGroup(
                      title: "سجل البحث",
                      searches: searchHistory,
                      onSearchTap: (search) {
                        print(search);
                        makeSearch(context, search);
                      },
                      onDeleteAllTap: () async {
                        if (searchHistory.isEmpty) return;
                        searchHistory = [];
                        await SharedPreferencesHelper.removeData(
                          key: Constants.searchKey,
                        );
                        if (context.mounted) setState(() {});
                      },
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void makeSearch(BuildContext context, String search) {
    if (isSearching && search.isEmpty) {
      isSearching = false;
    } else if (!isSearching && search.isNotEmpty) {
      isSearching = true;
    }
    if (isSearching) {
      print("make new search");

      context.read<SmDiscoverBloc>().add(
        widget.type == SearchType.product
            ? BrowseProductsEvent(
                isReload: true,
                params: BrowseProductsParams(search: search),
              )
            : BrowseStoresEvent(
                isReload: true,
                params: BrowseStoresParams(search: search),
              ),
      );
    }
    searchController.text = search;
    setState(() {});
  }
}

class SearchesGroup extends StatelessWidget {
  const SearchesGroup({
    super.key,
    required this.searches,
    required this.title,
    this.onDeleteAllTap,
    required this.onSearchTap,
  });
  final List<String> searches;
  final String title;
  final void Function(String search) onSearchTap;
  final void Function()? onDeleteAllTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  height: 16 / 14,
                ),
              ),
              if (onDeleteAllTap != null)
                InkWell(
                  onTap: onDeleteAllTap,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  child: AppText(
                    " مسح الكل ",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      height: 19 / 10,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          if (searches.isEmpty)
            AppText.labelMedium("لا يوجد سجل للبحث")
          else
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: searches
                  .map<_SearchChip>(
                    (search) => _SearchChip(
                      label: search,
                      onTap: () {
                        onSearchTap(search);
                      },
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip({super.key, this.onTap, required this.label});
  final void Function()? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(22)),
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 4, 8, 5),
        decoration: BoxDecoration(
          color: Color(0xFFDADCEA),
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 12,
              color: AppColors.primary,
            ),
            SizedBox(width: 4),
            AppText(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w300,
                height: 19 / 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
