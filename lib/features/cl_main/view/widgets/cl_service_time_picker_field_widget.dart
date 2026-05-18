import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

class ClServiceTimePickerFieldWidget extends StatelessWidget {
  const ClServiceTimePickerFieldWidget({
    required this.title,
    required this.controller,
    this.onTap,
    super.key,
  });

  final String title;
  final TextEditingController controller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyMedium(title, color: const Color(0xFF656B78), fontWeight: FontWeight.w700),
        const SizedBox(height: 8),
        AbsorbPointer(
          absorbing: onTap == null,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            canRequestFocus: onTap != null,
            enableInteractiveSelection: false,
            showCursor: false,
            textAlign: TextAlign.start,
            style: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w600, fontSize: 16),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF1E2A78)),
              ),
              prefixIcon: const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF9CA3AF)),
            ),
          ),
        ),
      ],
    );
  }
}
