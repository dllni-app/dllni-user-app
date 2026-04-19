import 'package:dllni_user_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum SearchType { product, store, smartSearch }

class SearchWithTypeDropdown extends StatefulWidget {
  final void Function(SearchType type) onTypeSelected;

  final bool isExpanded;
  const SearchWithTypeDropdown({
    super.key,
    required this.onTypeSelected,
    this.isExpanded = false,
  });

  @override
  State<SearchWithTypeDropdown> createState() => _SearchWithTypeDropdownState();
}

class _SearchBar extends StatelessWidget {
  final bool isExpanded;

  final void Function() onTap;
  const _SearchBar({required this.isExpanded, required this.onTap});

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
  final void Function(SearchType) onTypeSelected;

  const _SearchDropdown({required this.onTypeSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFE3E6EC)),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 17,
              left: 8,
              right: 8,
            ),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: _SearchTypeOption(
                    label: 'عن منتج',
                    icon: FontAwesomeIcons.cookieBite,
                    type: SearchType.product,
                    onTap: onTypeSelected,
                  ),
                ),
                Expanded(
                  child: _SearchTypeOption(
                    label: 'عن متجر',
                    icon: FontAwesomeIcons.store,
                    type: SearchType.store,
                    onTap: onTypeSelected,
                  ),
                ),
                Expanded(
                  child: _SearchTypeOption(
                    label: 'بحث الذكي',
                    icon: FontAwesomeIcons.microphone,
                    type: SearchType.smartSearch,
                    onTap: onTypeSelected,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTypeOption extends StatelessWidget {
  final String label;

  final FaIconData icon;
  final SearchType type;
  final void Function(SearchType) onTap;
  const _SearchTypeOption({
    required this.label,
    required this.icon,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(34),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: FaIcon(icon, size: 12, color: AppColors.white),
            ),
            SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: 22 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchWithTypeDropdownState extends State<SearchWithTypeDropdown> {
  late bool _isExpanded;
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

  @override
  void initState() {
    _isExpanded = widget.isExpanded;
    super.initState();
  }
}
