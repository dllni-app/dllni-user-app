import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/app_config.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

/// Canonical HTTPS base for deep links (API Contract V1).
String deepLinkBase() => 'https://${AppConfig.deepLinkCanonicalHost}';

/// Same origin as [AppConfig.baseUrl] user API: `/api/v1/user`.
String deepLinkUserApiRoot() => deepLinkBase();

/// Restaurant (RS) store detail — matches `GET /api/v1/user/restaurants/{id}`.
String restaurantUrl(int id) => '${deepLinkUserApiRoot()}/restaurant/$id';

/// Restaurant (RS) product — matches `GET /api/v1/user/products/{id}`.
String restaurantProductUrl(int id) => '${deepLinkUserApiRoot()}/product/$id';

/// Supermarket store — matches `GET /api/v1/user/supermarket/stores/{id}`.
String supermarketStoreUrl(int id) => '${deepLinkUserApiRoot()}/store/$id';

/// Vote follow-up — matches `.../restaurants/votes/{voteId}`.
String voteUrl(int id) => '${deepLinkUserApiRoot()}/vote/$id';

/// Prefer [shareToken] when present; otherwise numeric [id].
/// Matches `.../restaurants/group-orders/{idOrToken}`.
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
Future<void> shareDeepLinkUrl(String url, {String? subject, BuildContext? context}) async {
  try {
    await SharePlus.instance.share(ShareParams(text: url, subject: subject));
  } catch (_) {
    if (context?.mounted == true) {
      AppToast.showToast(context: context!, message: 'تعذر مشاركة الرابط', type: ToastificationType.error);
    }
  }
}
