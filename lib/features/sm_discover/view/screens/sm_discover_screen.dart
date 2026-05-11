import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/search_with_type_dropdown.dart';
import '../manager/bloc/sm_discover_bloc.dart';
import '../widgets/smart_search_sheet.dart';
import 'sm_main_discover_view.dart';
import 'sm_search_view.dart';

@AutoRoutePage(path: "/sm_discover")
class SmDiscoverScreen extends StatefulWidget {
  final SmDiscoverScreenParams params;

  const SmDiscoverScreen({super.key, required this.params});

  @override
  State<SmDiscoverScreen> createState() => _SmDiscoverScreenState();
}

class SmDiscoverScreenParams {
  final int selectedView;
  final bool expandSearch;
  final int? shoppingListId;

  SmDiscoverScreenParams({
    this.selectedView = 0,
    this.expandSearch = false,
    this.shoppingListId,
  });
}

class _SmDiscoverScreenState extends State<SmDiscoverScreen> {
  late int _selectedView;
  SearchType searchType = SearchType.product;

  /// One-shot query from smart search sheet when opening the search tab.
  String? _smartSearchInitialQuery;
  bool get _isShoppingListMode => widget.params.shoppingListId != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SmDiscoverBloc>(),
      child: Scaffold(
        backgroundColor: _selectedView == 0
            ? Color(0xFFF9FAFB)
            : Color(0xFFEFEFEF),
        body: PopScope(
          canPop: _isShoppingListMode || _selectedView == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!_isShoppingListMode && _selectedView == 1) {
              _selectedView = 0;
              _smartSearchInitialQuery = null;
              setState(() {});
            }
          },
          child: IndexedStack(
            index: _selectedView,
            children: [
              SmMainDiscoverView(
                expandSearch: widget.params.expandSearch,
                onTypeSelected: (type) async {
                  if (type == SearchType.smartSearch) {
                    final words = await showModalBottomSheet<List<String>>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const SmartSearchSheet(isSupermarket: true,),
                    );
                    if (!context.mounted || words == null || words.isEmpty)
                      return;
                    searchType = SearchType.product;
                    _smartSearchInitialQuery = words.join(' , ');
                    _selectedView = 1;
                    setState(() {});
                    return;
                  } else {
                    searchType = type;
                    if (_selectedView == 0) {
                      _selectedView = 1;
                      setState(() {});
                    }
                  }
                },
              ),
              SmSearchView(
                key: ValueKey<String>(
                  '${searchType}_${_smartSearchInitialQuery ?? ''}',
                ),
                type: searchType,
                initialSearch: _smartSearchInitialQuery,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _selectedView = _isShoppingListMode ? 1 : widget.params.selectedView;
    if (_isShoppingListMode) {
      searchType = SearchType.product;
    }
    super.initState();
  }
}
