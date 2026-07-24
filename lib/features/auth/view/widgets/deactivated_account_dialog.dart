import 'package:flutter/material.dart';

class DeactivatedAccountDialog extends StatelessWidget {
  final String message;

  const DeactivatedAccountDialog({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.block_rounded,
        color: Theme.of(context).colorScheme.error,
        size: 42,
      ),
      title: const Text(
        'تم إلغاء تفعيل الحساب',
        textAlign: TextAlign.center,
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('حسناً'),
        ),
      ],
    );
  }
}
