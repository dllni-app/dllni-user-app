import 'package:flutter/material.dart';

import '../../../../core/widgets/search_with_type_dropdown.dart';
import 'sm_search_view_v2.dart';

/// Backward-compatible name for callers that still import the old search view.
/// The implementation is now backend-powered in [SmSearchViewV2].
class SmSearchView extends SmSearchViewV2 {
  const SmSearchView({
    Key? key,
    required SearchType type,
    String? initialSearch,
  }) : super(key: key, type: type, initialSearch: initialSearch);
}
