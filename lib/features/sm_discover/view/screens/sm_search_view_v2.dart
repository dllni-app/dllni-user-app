import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/search/popular_searches_model.dart';
import '../../../../core/widgets/download_more.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../../core/widgets/loading_list.dart';
import '../../../../core/widgets/search_field_with_voice.dart';
import '../../../../core/widgets/search_with_type_dropdown.dart';
import '../../data/source/sm_discover_remote_data_source.dart';
import '../../domain/usecases/browse_products_use_case.dart';
import '../../domain/usecases/browse_stores_use_case.dart';
import '../manager/bloc/sm_discover_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/searches_group.dart';
import '../widgets/smart_search_sheet.dart';
import '../widgets/store_card.dart';

class SmSearchViewV2 extends StatefulWidget {
  const SmSearchViewV2({super.key, required this.type, this.initialSearch});

  final SearchType type;
  final String? initialSearch;

  @override
  State<SmSearchViewV2> createState() => _SmSearchViewV2State();
}

class _SmSearchViewV2State extends State<SmSearchViewV2> {
  late List<String> searchHistory;
  late TextEditingController searchController;
  late Future<PopularSearchesModel> _popularSearchesFuture;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchHistory =
        SharedPreferencesHelper.sharedPreferences!.getStringList(
          Constants.searchKey,
        ) ??
        <String>[];
    _popularSearchesFuture = getIt<SmDiscoverRemoteDataSource>()
        .fetchPopularSearches();

    final initial = widget.initialSearch?.trim();
    if (initial != null && initial.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _submitSearch(context, initial);
      });
    }
  }

  @override
  void didUpdateWidget(covariant SmSearchViewV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialSearch?.trim();
    final previous = oldWidget.initialSearch?.trim();
    if (next != null && next.isNotEmpty && next != previous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _submitSearch(context, next);
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24 + MediaQuery.paddingOf(context).top),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchFieldWithVoice(
            backgroundColor: const Color(0xFFF9FAFB),
            controller: searchController,
            hintText: widget.type == SearchType.product
                ? 'ابحث عن منتج...'
                : 'ابحث عن متجر...',
            onVoiceTap: widget.type == SearchType.store
                ? null
                : () => _openSmartSearch(context),
            onSearch: (search) => _submitSearch(context, search),
          ),
        ),
        if (isSearching)
          Expanded(child: _buildResults(context))
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              child: Column(
                children: [
                  FutureBuilder<PopularSearchesModel>(
                    future: _popularSearchesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      return SearchesGroup(
                        title: 'الأكثر بحثاً من قبل المستخدمين',
                        emptyText: 'لا توجد عمليات بحث شائعة حالياً',
                        searches: snapshot.data?.searches ?? const <String>[],
                        onSearchTap: (search) =>
                            _submitSearch(context, search),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFDBDCDE)),
                  const SizedBox(height: 16),
                  SearchesGroup(
                    title: 'سجل البحث',
                    emptyText: 'لا يوجد سجل للبحث',
                    searches: searchHistory,
                    onSearchTap: (search) => _submitSearch(context, search),
                    onDeleteAllTap: () async {
                      if (searchHistory.isEmpty) return;
                      searchHistory = <String>[];
                      await SharedPreferencesHelper.removeData(
                        key: Constants.searchKey,
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResults(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 20),
          child: AppText(
            'نتائج البحث',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 26 / 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: widget.type == SearchType.product
              ? _buildProductResults(context)
              : _buildStoreResults(context),
        ),
      ],
    );
  }

  Widget _buildProductResults(BuildContext context) {
    return BlocBuilder<SmDiscoverBloc, SmDiscoverState>(
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
          successWidget: () => GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 7,
              mainAxisSpacing: 12,
              mainAxisExtent: 232,
            ),
            padding: const EdgeInsetsDirectional.all(20),
            itemCount: state.browseProducts!.listLength(1),
            itemBuilder: (context, index) {
              if (state.browseProducts!.length <= index) {
                if (state.browseProducts!.length == index) {
                  context.read<SmDiscoverBloc>().add(
                    BrowseProductsEvent(
                      isReload: false,
                      params: BrowseProductsParams(
                        page: state.browseProducts!.pageNumber,
                        search: searchController.text.trim(),
                      ),
                    ),
                  );
                }
                return const DownloadMore();
              }
              return ProductCard(product: state.browseProducts![index]);
            },
          ),
          failedWidget: Center(
            child: FailureWidget(
              message: state.errorMessage.toString(),
              onRetry: () => _makeSearch(context, searchController.text),
            ),
          ),
          onTapRetry: () => _makeSearch(context, searchController.text),
        );
      },
    );
  }

  Widget _buildStoreResults(BuildContext context) {
    return BlocBuilder<SmDiscoverBloc, SmDiscoverState>(
      buildWhen: (previous, current) =>
          previous.browseStores != current.browseStores,
      builder: (context, state) {
        return state.browseStores!.builder(
          loadingWidget: Padding(
            padding: const EdgeInsets.all(20),
            child: LoadingGrid(
              heightCard: 180,
              borderRadius: 24,
              length: 6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 16,
            ),
          ),
          emptyWidget: Center(
            child: AppText.labelMedium(
              'لا يوجد متاجر',
              fontWeight: FontWeight.w400,
            ),
          ),
          successWidget: () => GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 16,
              mainAxisExtent: 180,
            ),
            padding: const EdgeInsetsDirectional.all(20),
            itemCount: state.browseStores!.listLength(1),
            itemBuilder: (context, index) {
              if (state.browseStores!.length <= index) {
                if (state.browseStores!.length == index) {
                  context.read<SmDiscoverBloc>().add(
                    BrowseStoresEvent(
                      isReload: false,
                      params: BrowseStoresParams(
                        page: state.browseStores!.pageNumber,
                        search: searchController.text.trim(),
                      ),
                    ),
                  );
                }
                return const DownloadMore();
              }
              return StoreCard(store: state.browseStores![index]);
            },
          ),
          failedWidget: Center(
            child: FailureWidget(
              message: state.errorMessage.toString(),
              onRetry: () => _makeSearch(context, searchController.text),
            ),
          ),
          onTapRetry: () => _makeSearch(context, searchController.text),
        );
      },
    );
  }

  Future<void> _openSmartSearch(BuildContext context) async {
    final words = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SmartSearchSheet(isSupermarket: true),
    );
    if (!mounted || words == null || words.isEmpty) return;
    _submitSearch(context, words.join(' , '));
  }

  void _submitSearch(BuildContext context, String rawSearch) {
    final search = rawSearch.trim();
    if (search.isEmpty) return;
    _makeSearch(context, search);
    _rememberSearch(search);
  }

  void _makeSearch(BuildContext context, String search) {
    final normalized = search.trim();
    if (normalized.isEmpty) {
      isSearching = false;
      searchController.clear();
      setState(() {});
      return;
    }

    isSearching = true;
    searchController.text = normalized;
    searchController.selection = TextSelection.collapsed(
      offset: normalized.length,
    );

    context.read<SmDiscoverBloc>().add(
      widget.type == SearchType.product
          ? BrowseProductsEvent(
              isReload: true,
              params: BrowseProductsParams(search: normalized),
            )
          : BrowseStoresEvent(
              isReload: true,
              params: BrowseStoresParams(search: normalized),
            ),
    );
    setState(() {});
  }

  void _rememberSearch(String search) {
    searchHistory.removeWhere((word) => word == search);
    searchHistory.insert(0, search);
    if (searchHistory.length > 20) {
      searchHistory = searchHistory.take(20).toList(growable: true);
    }
    SharedPreferencesHelper.sharedPreferences!.setStringList(
      Constants.searchKey,
      searchHistory,
    );
    if (mounted) setState(() {});
  }
}
