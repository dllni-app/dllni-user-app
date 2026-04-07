
import 'package:flutter/material.dart';

class DownloadMore extends StatelessWidget {
  const DownloadMore({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF9CA3AF),
            constraints: BoxConstraints(
              maxWidth: 14,
              maxHeight: 14,
            ),
          ),
          SizedBox(width: 8),
          Text(
            "جاري تحميل المزيد...",
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}