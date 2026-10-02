import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
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
import '../../../profile/domain/services/user_location_service.dart';
import '../../domain/usecases/browse_stores_use_case.dart';
import '../manager/bloc/sm_discover_bloc.dart';
import '../widgets/store_card.dart';

class SmMainDiscoverView extends StatefulWidget {
  final void Function(SearchType type) onTypeSelected;
  final bool expandSearch;

  const SmMainDiscoverView({
    super.key,
    required this.onTypeSelected,
    this.expandSearch = false,
  });

  @override
  State<SmMainDiscoverView> createState() => _SmMainDiscoverViewState();
}

class _SmMainDiscoverViewState extends State<SmMainDiscoverView> {
  String _selectedSort = 'nearestBy';
  final List<String> _sortOptions = ['nearestBy', 'rating', 'alphabet'];
  double? _latitude;
  double? _longitude;
  bool _openNowOnly = false;
  bool _featuredOnly = false;
  double? _minimumRating;

  @override
  void initState() {
    super.initState();
    _loadStoresWithLocation();
  }

  Future<void> _loadStoresWithLocation() async {
    final location = await getIt<UserLocationService>().getCurrentPosition();
    if (!mounted) return;
    _latitude = location.latitude;
    _longitude = location.longitude;
    if ((_latitude == null || _longitude == null) &&
        _selectedSort == 'nearestBy') {
      _selectedSort = 'rating';
    }
    _reloadStores();
  }

  void _reloadStores() {
    context.read<SmDiscoverBloc>().add(
      BrowseStoresEvent(
        isReload: true,
        params: BrowseStoresParams(
          sort: _selectedSort,
          latitude: _latitude,
          longitude: _longitude,
          openNow: _openNowOnly ? true : null,
          isFeatured: _featuredOnly ? true : null,
          averageRatingMin: _minimumRating,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSimpleAppBarWithSearch(
          accentColor: SharedPlatformColors.supermarket,
          title: 'تصفح',
          onTypeSelected: widget.onTypeSelected,
          isSearchExpand: widget.expandSearch,
        ),
        const SizedBox(height: 16),
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
                      '${state.browseStores?.total ?? 0} متجر متاح',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
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
                      _reloadStores();
                    },
                    itemBuilder: (_) => _sortOptions
                        .map(
                          (option) => PopupMenuItem<String>(
                            value: option,
                            child: AppText(
                              option == 'alphabet'
                                  ? 'الترتيب الأبجدي'
                                  : option == 'rating'
                                  ? 'الأعلى تقييماً'
                                  : 'الأقرب إلي',
                              style: TextStyle(
                                color: _selectedSort == option
                                    ? SharedPlatformColors.supermarket
                                    : const Color(0xFF6B7280),
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
                            'ترتيب حسب: ' +
                                (_selectedSort == 'alphabet'
                                    ? 'الترتيب الأبجدي'
                                    : _selectedSort == 'rating'
                                    ? 'الأعلى تقييماً'
                                    : 'الأقرب إلي'),
                            style: const TextStyle(
                              color: SharedPlatformColors.supermarket,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 20 / 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const FaIcon(
                            FontAwesomeIcons.angleDown,
                            size: 12,
                            color: SharedPlatformColors.supermarket,
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
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              FilterChip(
                label: const Text('مفتوح الآن'),
                selected: _openNowOnly,
                onSelected: (value) {
                  setState(() => _openNowOnly = value);
                  _reloadStores();
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('متاجر مميزة'),
                selected: _featuredOnly,
                onSelected: (value) {
                  setState(() => _featuredOnly = value);
                  _reloadStores();
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('4+ نجوم'),
                selected: _minimumRating == 4,
                onSelected: (value) {
                  setState(() => _minimumRating = value ? 4 : null);
                  _reloadStores();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: BlocBuilder<SmDiscoverBloc, SmDiscoverState>(
            buildWhen: (previous, current) =>
                previous.browseStores != current.browseStores,
            builder: (context, state) {
              return state.browseStores!.builder(
                loadingWidget: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LoadingGrid(
                    heightCard: 180,
                    borderRadius: 24,
                    length: 6,
                    crossAxisSpacing: 11,
                    mainAxisSpacing: 17,
                  ),
                ),
                emptyWidget: AppText.labelMedium(
                  'لا يوجد متاجر',
                  fontWeight: FontWeight.w400,
                ),
                successWidget: () {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 180,
                        ),
                    padding: const EdgeInsetsDirectional.all(20),
                    itemBuilder: (context, index) {
                      if (state.browseStores!.length <= index) {
                        if (state.browseStores!.length == index) {
                          context.read<SmDiscoverBloc>().add(
                            BrowseStoresEvent(
                              isReload: false,
                              params: BrowseStoresParams(
                                page: state.browseStores!.pageNumber,
                                sort: _selectedSort,
                                latitude: _latitude,
                                longitude: _longitude,
                                openNow: _openNowOnly ? true : null,
                                isFeatured: _featuredOnly ? true : null,
                                averageRatingMin: _minimumRating,
                              ),
                            ),
                          );
                        }
                        return const DownloadMore();
                      }
                      return StoreCard(store: state.browseStores![index]);
                    },
                    itemCount: state.browseStores!.listLength(1),
                  );
                },
                failedWidget: Center(
                  child: FailureWidget(
                    message: state.errorMessage.toString(),
                    onRetry: () {
                      _reloadStores();
                    },
                  ),
                ),
                onTapRetry: _reloadStores,
              );
            },
          ),
        ),
      ],
    );
  }
}
