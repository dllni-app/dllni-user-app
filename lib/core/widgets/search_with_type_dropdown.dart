import 'package:dllni_user_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum SearchType { product, store }

class SearchWithTypeDropdown extends StatefulWidget {
  const SearchWithTypeDropdown({
    super.key,
    required this.onTypeSelected,
    this.isExpanded = false,
  });

  final void Function(SearchType type) onTypeSelected;
  final bool isExpanded;

  @override
  State<SearchWithTypeDropdown> createState() => _SearchWithTypeDropdownState();
}

class _SearchWithTypeDropdownState extends State<SearchWithTypeDropdown> {
  late bool _isExpanded;
  @override
  void initState() {
    _isExpanded = widget.isExpanded;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => setState(() => _isExpanded = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Color(0x0F2F2B3D),
          borderRadius: BorderRadius.circular(_isExpanded ? 12 : 24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchBar(
              isExpanded: _isExpanded,
              onTap: () => setState(() => _isExpanded = !_isExpanded),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? _SearchDropdown(onTypeSelected: widget.onTypeSelected)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.isExpanded, required this.onTap});

  final bool isExpanded;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 12),
            Text(
              isExpanded
                  ? 'حدد ما تود البحث عنه'
                  : 'ابحث عن متجر أو نوع منتج معين...',
              style: TextStyle(
                color: isExpanded ? Colors.black : Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 22 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchDropdown extends StatelessWidget {
  const _SearchDropdown({required this.onTypeSelected});

  final void Function(SearchType) onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFE3E6EC)),
          _SearchTypeOption(
            label: 'البحث عن منتج',
            icon: FontAwesomeIcons.cookieBite,
            iconBg: Color(0x261E2A78),
            iconColor: AppColors.primary,
            type: SearchType.product,
            onTap: onTypeSelected,
          ),
          _SearchTypeOption(
            label: 'البحث عن متجر',
            icon: FontAwesomeIcons.store,
            iconBg: AppColors.accent.withValues(alpha: .12),
            iconColor: AppColors.accent,
            type: SearchType.store,
            onTap: onTypeSelected,
          ),
        ],
      ),
    );
  }
}

class _SearchTypeOption extends StatelessWidget {
  const _SearchTypeOption({
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.type,
    required this.onTap,
  });

  final String label;
  final FaIconData icon;
  final Color iconBg;
  final Color iconColor;
  final SearchType type;
  final void Function(SearchType) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: iconBg,
              child: FaIcon(icon, size: 12, color: iconColor),
            ),
            SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 22 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
