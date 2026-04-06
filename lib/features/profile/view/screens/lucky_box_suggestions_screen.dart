import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../widgets/expandable_numbered_section.dart';
import '../widgets/filled_text_field.dart';
import '../widgets/lucky_suggestion_card.dart';
import '../widgets/personal_details_app_bar.dart';

@AutoRoutePage()
class LuckyBoxSuggestionsScreen extends StatefulWidget {
  const LuckyBoxSuggestionsScreen({super.key});

  @override
  State<LuckyBoxSuggestionsScreen> createState() =>
      _LuckyBoxSuggestionsScreenState();
}

class _LuckyBoxSuggestionsScreenState
    extends State<LuckyBoxSuggestionsScreen> {
  final TextEditingController _budgetController = TextEditingController(
    text: '0.00',
  );
  final TextEditingController _rangeController = TextEditingController(
    text: 'إضافة نطاق للبحث',
  );
  final TextEditingController _constraintsController = TextEditingController(
    text: 'حدد القيود',
  );
  final TextEditingController _restaurantTypeController = TextEditingController(
    text: 'حدد نوع المطاعم',
  );

  bool _isSectionExpanded = false;
  List<LuckySuggestionItem> _suggestions = const [
    LuckySuggestionItem(
      badge: 'الأوفر',
      productsCount: 3,
      title: 'بيتزا هت',
      details: '2 بيتزا عائلي فصول أربعة، بيتزا وسط سيخ',
      secondaryInfo: '2,000 ل.س',
    ),
    LuckySuggestionItem(
      badge: 'الأسرع',
      productsCount: 4,
      title: 'برغرايزر',
      details: '2 برغر دبل جبنة، 2 برغر سيخ',
      secondaryInfo: '12 دقيقة',
    ),
    LuckySuggestionItem(
      badge: 'المتوازن',
      productsCount: 5,
      title: 'الأسمر',
      details: '1 وجبة عائلي، 3 ناجتس، 2 سلطة، 4 كولا',
      secondaryInfo: '20 دقيقة - 4,000 ل.س',
    ),
  ];

  @override
  void dispose() {
    _budgetController.dispose();
    _rangeController.dispose();
    _constraintsController.dispose();
    _restaurantTypeController.dispose();
    super.dispose();
  }

  void _refreshSuggestions() {
    setState(() {
      _suggestions = [..._suggestions.skip(1), _suggestions.first];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            const PersonalDetailsAppBar(title: 'صندوق الحظ'),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                child: Column(
                  children: [
                    ExpandableNumberedSection(
                      sectionNumber: '1',
                      title: 'تخصيص البحث',
                      isExpanded: _isSectionExpanded,
                      onHeaderTap: () {
                        setState(() {
                          _isSectionExpanded = !_isSectionExpanded;
                        });
                      },
                      child: Column(
                        children: [
                          FilledTextField(
                            label: 'ميزانية الشخص الواحد',
                            controller: _budgetController,
                            readOnly: true,
                            suffixIcon: Padding(
                              padding: const EdgeInsetsDirectional.only(end: 10),
                              child: Center(
                                widthFactor: 1,
                                child: AppText.bodyMedium(
                                  'ل.س',
                                  color: const Color(0xff9CA3AF),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          FilledTextField(
                            label: 'نطاق البحث',
                            controller: _rangeController,
                            readOnly: true,
                            suffixIcon: const Icon(Icons.chevron_left),
                          ),
                          const SizedBox(height: 14),
                          FilledTextField(
                            label: 'هل هناك قيود؟',
                            controller: _constraintsController,
                            readOnly: true,
                            suffixIcon:
                                const Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                          const SizedBox(height: 14),
                          FilledTextField(
                            label: 'نوع المطاعم',
                            controller: _restaurantTypeController,
                            readOnly: true,
                            suffixIcon:
                                const Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._suggestions.map(
                      (item) => Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 12),
                        child: LuckySuggestionCard(item: item),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: _refreshSuggestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: context.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: AppText.labelLarge(
                        'تحديث الاقتراحات',
                        color: context.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.error.withAlpha(200)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: AppText.labelLarge(
                        'إلغاء',
                        color: context.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
