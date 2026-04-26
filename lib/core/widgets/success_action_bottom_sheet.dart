import 'package:flutter/material.dart';

class SuccessActionBottomSheet extends StatelessWidget {
  final String title;
  final String followUpLabel;
  final String shareLabel;
  final VoidCallback onFollowUp;
  final VoidCallback onShare;
  final Widget? icon;

  const SuccessActionBottomSheet({
    super.key,
    required this.title,
    required this.followUpLabel,
    required this.shareLabel,
    required this.onFollowUp,
    required this.onShare,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ?? Icon(Icons.verified, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onFollowUp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(followUpLabel),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: onShare,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 4,
                  shadowColor: Colors.black26,
                ),
                child: Text(shareLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

