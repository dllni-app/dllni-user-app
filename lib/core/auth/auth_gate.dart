import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../session/user_session_keys.dart';

/// Central helper for guest mode.
///
/// Public browsing should not require authentication. Protected actions call
/// [requireAuth]; when login succeeds, [resumePendingActionIfAny] returns the
/// user to the original screen and runs the stored action.
typedef PendingAuthAction = FutureOr<void> Function();

abstract final class AuthGate {
  static PendingAuthAction? _pendingAction;

  static bool get isAuthenticated {
    final token = (SharedPreferencesHelper.getData(key: UserSessionKeys.token) ?? '')
        .toString()
        .trim();
    return token.isNotEmpty;
  }

  static Future<bool> requireAuth(
    BuildContext context, {
    required PendingAuthAction onAuthenticated,
    String message = 'يرجى تسجيل الدخول للمتابعة',
  }) async {
    if (isAuthenticated) {
      await Future<void>.sync(onAuthenticated);
      return true;
    }

    _pendingAction = onAuthenticated;

    if (context.mounted && message.trim().isNotEmpty) {
      AppToast.showToast(
        context: context,
        message: message,
        type: ToastificationType.info,
      );
    }

    if (context.mounted) {
      await Navigator.of(context).pushNamed('/login');
    }

    return false;
  }

  static Future<bool> resumePendingActionIfAny(BuildContext context) async {
    final action = _pendingAction;
    if (action == null) return false;

    _pendingAction = null;

    if (context.mounted) {
      Navigator.of(context).popUntil((route) {
        if (route.isFirst) return true;
        return route.settings.name != '/login' &&
            route.settings.name != '/verify-account';
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(Future<void>.sync(action));
    });

    return true;
  }

  static void clearPendingAction() {
    _pendingAction = null;
  }
}
