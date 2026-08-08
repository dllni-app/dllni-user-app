import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';

class SearchesGroup extends StatelessWidget {
  final List<String> searches;
  final String title;
  final String emptyText;
  final void Function(String search) onSearchTap;
  final void Function()? onDeleteAllTap;

  const SearchesGroup({
    super.key,
    required this.searches,
    required this.title,
    this.emptyText = 'لا يوجد سجل للبحث',
    this.onDeleteAllTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  height: 16 / 14,
                ),
              ),
              if (onDeleteAllTap != null)
                InkWell(
                  onTap: onDeleteAllTap,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: AppText(
                    ' مسح الكل ',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      height: 19 / 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (searches.isEmpty)
            AppText.labelMedium(emptyText)
          else
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: searches
                  .map<_SearchChip>(
                    (search) => _SearchChip(
                      label: search,
                      onTap: () => onSearchTap(search),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final void Function()? onTap;
  final String label;

  const _SearchChip({this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(22)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 4, 8, 5),
        decoration: const BoxDecoration(
          color: Color(0xFFDADCEA),
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 12,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            AppText(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w300,
                height: 19 / 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
