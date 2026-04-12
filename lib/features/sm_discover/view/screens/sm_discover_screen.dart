import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/search_with_type_dropdown.dart';
import 'sm_main_discover_view.dart';
import 'sm_search_view.dart';

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

@AutoRoutePage(path: "/sm_discover")
class SmDiscoverScreen extends StatefulWidget {
  const SmDiscoverScreen({super.key, required this.params});

  final SmDiscoverScreenParams params;

  @override
  State<SmDiscoverScreen> createState() => _SmDiscoverScreenState();
}

class _SmDiscoverScreenState extends State<SmDiscoverScreen> {
  late int _selectedView;
  SearchType searchType = SearchType.product;
  bool get _isShoppingListMode => widget.params.shoppingListId != null;

  @override
  void initState() {
    _selectedView = _isShoppingListMode ? 1 : widget.params.selectedView;
    if (_isShoppingListMode) {
      searchType = SearchType.product;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedView == 0 ? Color(0xFFF9FAFB) : Color(0xFFEFEFEF),
      body: PopScope(
        canPop: _isShoppingListMode || _selectedView == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!_isShoppingListMode && _selectedView == 1) {
            _selectedView = 0;
            setState(() {});
          }
        },
        child: IndexedStack(
          index: _selectedView,
          children: [
            SmMainDiscoverView(
              expandSearch: widget.params.expandSearch,
              onTypeSelected: (type) {
                searchType = type;
                if (_selectedView == 0) {
                  _selectedView = 1;
                  setState(() {});
                }
              },
            ),
            SmSearchView(
              type: searchType,
              shoppingListId: widget.params.shoppingListId,
            ),
          ],
        ),
      ),
    );
  }
}
