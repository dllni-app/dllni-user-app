import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/app_config.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

/// Canonical HTTPS base for deep links (API Contract V1).
String deepLinkBase() =>
    '${AppConfig.deepLinkCanonicalScheme}://${AppConfig.deepLinkCanonicalHost}';

/// Alias retained for compatibility with existing call sites/tests.
String deepLinkUserApiRoot() => deepLinkBase();

/// Canonical product URL: `/product/{identifier}`.
String productUrl(int id) => '${deepLinkBase()}/product/$id';

/// Canonical restaurant URL: `/restaurant/{identifier}`.
String restaurantUrl(int id) => '${deepLinkUserApiRoot()}/restaurant/$id';

/// Canonical store URL: `/store/{identifier}`.
String storeUrl(int id) => '${deepLinkBase()}/store/$id';

/// Legacy alias kept for feature modules already importing this helper.
String restaurantProductUrl(int id) => '${deepLinkUserApiRoot()}/product/$id';

/// Legacy alias kept for feature modules already importing this helper.
String supermarketStoreUrl(int id) => '${deepLinkUserApiRoot()}/store/$id';

/// Canonical vote URL: `/vote/{identifier}`.
String voteUrl(int id) => '${deepLinkUserApiRoot()}/vote/$id';

/// Prefer [shareToken] when present; otherwise numeric [id].
/// Canonical group-order URL: `/group-order/{identifier}`.
String groupOrderUrl({int? id, String? shareToken}) {
  final t = shareToken?.trim();
  if (t != null && t.isNotEmpty) {
    return '${deepLinkUserApiRoot()}/group-order/${Uri.encodeComponent(t)}';
  }
  if (id != null && id > 0) {
    return '${deepLinkUserApiRoot()}/group-order/$id';
  }
  return deepLinkBase();
}

/// Opens the system share sheet with [url]. Optionally shows a toast on failure when [context] is mounted.
Future<void> shareDeepLinkUrl(
  String url, {
  String? subject,
  BuildContext? context,
}) async {
  try {
    await SharePlus.instance.share(ShareParams(text: url, subject: subject));
  } catch (_) {
    if (context?.mounted == true) {
      AppToast.showToast(
        context: context!,
        message: 'تعذر مشاركة الرابط',
        type: ToastificationType.error,
      );
    }
  }
}
