import 'package:flutter/material.dart';

class ToastComponent {
  static void showToast(BuildContext context, {required String msg}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}
