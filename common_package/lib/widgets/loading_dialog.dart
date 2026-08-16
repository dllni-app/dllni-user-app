import 'package:common_package/extensions/theme_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Loading {
  static BuildContext? _context;

  static Future<Future> show(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Loading._context = context;
        return AlertDialog(
          backgroundColor: context.onPrimary,
          content: Row(
            children: [
              CircularProgressIndicator(color: context.primary),
              const SizedBox(width: 10),
              Text(
                context.locale == const Locale('ar')
                    ? 'يتم التحميل...'
                    : 'Loading...',
                style: const TextStyle(color: Color(0xff000000)),
              ),
            ],
          ),
        );
      },
    );
  }

  static void close() {
    final dialogContext = Loading._context;
    Loading._context = null;

    if (dialogContext == null || !dialogContext.mounted) return;

    // Close the loading dialog route itself instead of popping the navigator's
    // current route. This matters when a success handler navigates before its
    // finally block calls Loading.close(): Navigator.pop() would otherwise pop
    // the newly opened screen and leave the loading dialog visible underneath.
    final route = ModalRoute.of(dialogContext);
    final navigator = route?.navigator;
    if (route != null && navigator != null && route.isActive) {
      navigator.removeRoute(route);
    }
  }

  static Widget bottomLoading(bool value, context) {
    return value
        ? Container(
            alignment: Alignment.center,
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: context.primaryColor),
            ),
          )
        : const SizedBox(height: 5, width: 5);
  }
}
