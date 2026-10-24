
import 'sm_search_view_v2.dart';

/// Backward-compatible name for callers that still import the old search view.
/// The implementation is now backend-powered in [SmSearchViewV2].
class SmSearchView extends SmSearchViewV2 {
  const SmSearchView({
    super.key,
    required super.type,
    super.initialSearch,
  });
}
