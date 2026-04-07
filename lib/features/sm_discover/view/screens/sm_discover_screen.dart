import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/search_with_type_dropdown.dart';
import 'sm_main_discover_view.dart';
import 'sm_search_view.dart';

@AutoRoutePage(path: "/discover")
class SmDiscoverScreen extends StatefulWidget {
  const SmDiscoverScreen({
    super.key,
    this.selectedView = 0,
    this.expandSearch = false,
  });
  final int selectedView;
  final bool expandSearch;

  @override
  State<SmDiscoverScreen> createState() => _SmDiscoverScreenState();
}

class _SmDiscoverScreenState extends State<SmDiscoverScreen> {
  late int _selectedView;
  SearchType searchType = SearchType.product;
  @override
  void initState() {
    _selectedView = widget.selectedView;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedView == 0
          ? Color(0xFFF9FAFB)
          : Color(0xFFEFEFEF),
      body: PopScope(
        canPop: _selectedView == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (_selectedView == 1) {
            _selectedView = 0;
            setState(() {});
          }
        },
        child: IndexedStack(
          index: _selectedView,
          children: [
            SmMainDiscoverView(
              expandSearch: widget.expandSearch,
              onTypeSelected: (type) {
                searchType = type;
                if (_selectedView == 0) {
                  _selectedView = 1;
                  setState(() {});
                }
              },
            ),
            SmSearchView(type: searchType),
          ],
        ),
      ),
    );
  }
}
