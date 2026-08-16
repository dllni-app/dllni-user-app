import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/search_with_type_dropdown.dart';
import '../../../sm_discover/view/widgets/smart_search_sheet.dart';
import '../manager/bloc/rs_discover_bloc.dart';
import 'rs_main_discover_view.dart';
import 'rs_search_view_v2.dart';

@AutoRoutePage(path: '/rs_discover')
class RsDiscoverScreen extends StatefulWidget {
  const RsDiscoverScreen({
    super.key,
    this.selectedView = 0,
    this.expandSearch = false,
    this.initialSearch,
  });

  final int selectedView;
  final bool expandSearch;
  final String? initialSearch;

  @override
  State<RsDiscoverScreen> createState() => _RsDiscoverScreenState();
}

class _RsDiscoverScreenState extends State<RsDiscoverScreen> {
  late int _selectedView;
  SearchType _searchType = SearchType.product;
  String? _smartSearchInitialQuery;

  @override
  void initState() {
    super.initState();
    final initialSearch = widget.initialSearch?.trim() ?? '';
    _smartSearchInitialQuery = initialSearch.isEmpty ? null : initialSearch;
    _selectedView = _smartSearchInitialQuery == null
        ? widget.selectedView.clamp(0, 1).toInt()
        : 1;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RsDiscoverBloc>()
        ..add(FetchDiscoverRestaurantsEvent(isReload: true)),
      child: Scaffold(
        backgroundColor: _selectedView == 0
            ? const Color(0xFFF9FAFB)
            : const Color(0xFFEFEFEF),
        body: PopScope(
          canPop: _selectedView == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop || _selectedView == 0) return;
            setState(() {
              _selectedView = 0;
              _smartSearchInitialQuery = null;
            });
          },
          child: IndexedStack(
            index: _selectedView,
            children: [
              RsMainDiscoverView(
                expandSearch: widget.expandSearch,
                onTypeSelected: (type) async {
                  if (type == SearchType.smartSearch) {
                    final words = await showModalBottomSheet<List<String>>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) =>
                          const SmartSearchSheet(isSupermarket: false),
                    );
                    if (!context.mounted || words == null || words.isEmpty) {
                      return;
                    }
                    setState(() {
                      _searchType = SearchType.product;
                      _smartSearchInitialQuery = words.join(' , ');
                      _selectedView = 1;
                    });
                    return;
                  }

                  setState(() {
                    _searchType = type;
                    _smartSearchInitialQuery = null;
                    _selectedView = 1;
                  });
                },
              ),
              RsSearchViewV2(
                key: ValueKey<String>(
                  '${_searchType}_${_smartSearchInitialQuery ?? ''}',
                ),
                type: _searchType,
                initialSearch: _smartSearchInitialQuery,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
