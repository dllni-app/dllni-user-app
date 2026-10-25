import 'dart:developer';

import 'package:common_package/common_package.dart';

import '../di/injection.dart';
import '../../features/auth/domain/usecases/fetch_current_user_use_case.dart';
import 'user_session_keys.dart';
import 'user_session_store.dart';

/// Restores cached user data and refreshes it from `/api/v1/user/me` in the background.
class UserSessionSyncService {
  UserSessionSyncService._();

  static Future<void> syncOnStartup() async {
    await UserSessionStore.restoreFromDisk();
    await refreshAuthenticatedUser();
  }

  /// Resolve the identity associated with the currently persisted bearer token.
  static Future<void> refreshAuthenticatedUser() async {
    final authToken =
        (SharedPreferencesHelper.getData(key: UserSessionKeys.token) ?? '')
            .toString()
            .trim();
    if (authToken.isEmpty) {
      return;
    }

    try {
      final result = await getIt<FetchCurrentUserUseCase>()(NoParams());
      await result.fold(
        (failure) async {
          log('Background user sync skipped: ${failure.message}');
        },
        (response) async {
          final user = response.user;
          if (user == null) return;
          final activeToken =
              (SharedPreferencesHelper.getData(key: UserSessionKeys.token) ??
                      '')
                  .toString()
                  .trim();
          if (activeToken != authToken) return;
          await UserSessionStore.writeAndMirror(user);
          log('Background user sync completed.');
        },
      );
    } catch (error, stackTrace) {
      log('Background user sync failed: $error', stackTrace: stackTrace);
    }
  }
}
