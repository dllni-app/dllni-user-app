import 'dart:convert';
import 'dart:io';

import 'package:common_package/common_package.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toastification/toastification.dart';

import 'force_update_dialog.dart';

enum UpdateCheckStatus { upToDate, updateInProgress, updateRequired }

class UpdateCheckResult {
  const UpdateCheckResult({required this.status, this.storeUrl});

  final UpdateCheckStatus status;
  final String? storeUrl;

  static const upToDate = UpdateCheckResult(status: UpdateCheckStatus.upToDate);

  static const updateInProgress = UpdateCheckResult(
    status: UpdateCheckStatus.updateInProgress,
  );

  static UpdateCheckResult updateRequired(String storeUrl) {
    return UpdateCheckResult(
      status: UpdateCheckStatus.updateRequired,
      storeUrl: storeUrl,
    );
  }
}

class _RemoteIOSAppInfo {
  const _RemoteIOSAppInfo({required this.version, required this.storeUrl});

  final String version;
  final String storeUrl;
}

class UpdateService {
  static Future<void> checkOnStartup({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (kIsWeb) return;

    try {
      final UpdateCheckResult result = await _performCheck();
      if (result.status == UpdateCheckStatus.updateRequired &&
          result.storeUrl != null) {
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          await showForceUpdateDialog(
            context: context,
            storeUrl: result.storeUrl!,
          );
        }
      }
    } catch (error) {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        AppToast.showToast(
          context: context,
          message: "يجب تثبيت التطبيق من المتجر الرسمي للتمتع بتجربة أفضل",
          type: ToastificationType.error,
        );
      }
    }
  }

  static Future<UpdateCheckResult> _performCheck() async {
    if (Platform.isAndroid) {
      return _checkUpdateForAndroid();
    }
    if (Platform.isIOS) {
      // return UpdateCheckResult.upToDate;
      return _checkUpdateForIOS();
    }
    return UpdateCheckResult.upToDate;
  }

  static Future<UpdateCheckResult> _checkUpdateForAndroid() async {
    final AppUpdateInfo info = await InAppUpdate.checkForUpdate();

    if (info.updateAvailability != UpdateAvailability.updateAvailable) {
      return UpdateCheckResult.upToDate;
    }

    if (info.immediateUpdateAllowed) {
      final AppUpdateResult result = await InAppUpdate.performImmediateUpdate();
      if (result == AppUpdateResult.userDeniedUpdate) {
        SystemNavigator.pop(animated: true);
      }
      return UpdateCheckResult.updateInProgress;
    }

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return UpdateCheckResult.updateRequired(
      'https://play.google.com/store/apps/details?id=${packageInfo.packageName}',
    );
  }

  static Future<UpdateCheckResult> _checkUpdateForIOS() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final _RemoteIOSAppInfo? remoteInfo = await _getRemoteIOSAppInfo(
      packageInfo.packageName,
    );

    if (remoteInfo == null) {
      throw Exception('تعذر التحقق من إصدار التطبيق في App Store');
    }

    if (!_isRemoteVersionGreater(
      localVersion: packageInfo.version,
      remoteVersion: remoteInfo.version,
    )) {
      return UpdateCheckResult.upToDate;
    }

    return UpdateCheckResult.updateRequired(remoteInfo.storeUrl);
  }

  static Future<_RemoteIOSAppInfo?> _getRemoteIOSAppInfo(
    String bundleId,
  ) async {
    final Uri url = Uri.parse(
      'https://itunes.apple.com/lookup?bundleId=$bundleId',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('تعذر الاتصال بـ App Store للتحقق من التحديث');
    }

    final Map<String, dynamic> decodedData =
        jsonDecode(response.body) as Map<String, dynamic>;
    final results = decodedData['results'];
    if (results is! List || results.isEmpty) {
      return null;
    }

    final Map<String, dynamic> appInfo = results.first as Map<String, dynamic>;
    final version = appInfo['version'];
    final storeUrl = appInfo['trackViewUrl'];
    if (version is! String || storeUrl is! String) {
      return null;
    }

    return _RemoteIOSAppInfo(version: version, storeUrl: storeUrl);
  }

  static bool _isRemoteVersionGreater({
    required String localVersion,
    required String remoteVersion,
  }) {
    final List<int> localParts = localVersion
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    final List<int> remoteParts = remoteVersion
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();

    while (localParts.length < 3) {
      localParts.add(0);
    }
    while (remoteParts.length < 3) {
      remoteParts.add(0);
    }

    for (var index = 0; index < 3; index++) {
      if (remoteParts[index] > localParts[index]) {
        return true;
      }
      if (remoteParts[index] < localParts[index]) {
        return false;
      }
    }

    return false;
  }

  static String _mapErrorMessage(Object error) {
    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }

    final message = error.toString().trim();
    if (message.isNotEmpty && !message.startsWith('Exception:')) {
      return message;
    }

    if (message.startsWith('Exception:')) {
      final cleaned = message.replaceFirst('Exception:', '').trim();
      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }

    return Platform.isAndroid
        ? 'تعذر التحقق من التحديثات. يرجى تثبيت التطبيق من Google Play.'
        : 'تعذر التحقق من التحديثات. يرجى تثبيت التطبيق من App Store.';
  }

}
