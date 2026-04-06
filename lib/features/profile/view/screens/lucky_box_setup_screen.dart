import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../widgets/expandable_numbered_section.dart';
import '../widgets/filled_text_field.dart';
import '../widgets/lucky_box_count_action_button.dart';
import '../widgets/lucky_box_name_tags_wrap.dart';
import '../widgets/personal_details_app_bar.dart';

@AutoRoutePage()
class LuckyBoxSetupScreen extends StatefulWidget {
  const LuckyBoxSetupScreen({super.key});

  @override
  State<LuckyBoxSetupScreen> createState() => _LuckyBoxSetupScreenState();
}

class _LuckyBoxSetupScreenState extends State<LuckyBoxSetupScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _rangeController = TextEditingController();
  final TextEditingController _constraintsController = TextEditingController();
  final TextEditingController _restaurantTypeController =
      TextEditingController();
  final TextEditingController _memberNameController = TextEditingController();

  bool _isSectionExpanded = true;
  int _membersCount = 0;
  String? _selectedRange;
  String? _selectedConstraint;
  String? _selectedRestaurantType;
  final List<String> _memberNames = [];

  static const List<String> _rangeOptions = [
    'ضمن نفس المنطقة',
    'ضمن المدينة',
    'ضمن المحافظة',
  ];

  static const List<String> _constraintOptions = [
    'لا يوجد',
    'بدون بصل',
    'بدون طماطم',
    'بدون جلوتين',
  ];

  static const List<String> _restaurantTypeOptions = [
    'برغر',
    'بيتزا',
    'شرقي',
    'مشاوي',
    'حلويات',
  ];

  @override
  void dispose() {
    _budgetController.dispose();
    _rangeController.dispose();
    _constraintsController.dispose();
    _restaurantTypeController.dispose();
    _memberNameController.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final value = await _showSingleSelectionBottomSheet(
      title: 'نطاق البحث',
      options: _rangeOptions,
      selectedValue: _selectedRange,
    );
    if (!mounted || value == null) {
      return;
    }
    setState(() {
      _selectedRange = value;
      _rangeController.text = value;
    });
  }

  Future<void> _pickConstraint() async {
    final value = await _showSingleSelectionBottomSheet(
      title: 'هل هناك قيود؟',
      options: _constraintOptions,
      selectedValue: _selectedConstraint,
    );
    if (!mounted || value == null) {
      return;
    }
    setState(() {
      _selectedConstraint = value;
      _constraintsController.text = value;
    });
  }

  Future<void> _pickRestaurantType() async {
    final value = await _showSingleSelectionBottomSheet(
      title: 'نوع المطاعم',
      options: _restaurantTypeOptions,
      selectedValue: _selectedRestaurantType,
    );
    if (!mounted || value == null) {
      return;
    }
    setState(() {
      _selectedRestaurantType = value;
      _restaurantTypeController.text = value;
    });
  }

  Future<String?> _showSingleSelectionBottomSheet({
    required String title,
    required List<String> options,
    required String? selectedValue,
  }) async {
    var current = selectedValue;
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.titleMedium(
                      title,
                      fontWeight: FontWeight.w700,
                      color: context.primary,
                    ),
                    const SizedBox(height: 10),
                    ...options.map((option) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: AppText.bodyMedium(option),
                        trailing: Radio<String>(
                          value: option,
                          groupValue: current,
                          activeColor: context.primaryContainer,
                          onChanged: (value) {
                            setModalState(() {
                              current = value;
                            });
                          },
                        ),
                        onTap: () {
                          setModalState(() {
                            current = option;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(modalContext).pop(current);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: context.primary,
                          foregroundColor: context.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: AppText.labelLarge(
                          'تأكيد',
                          color: context.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _addMemberName() {
    final name = _memberNameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    setState(() {
      _memberNames.add(name);
      _memberNameController.clear();
    });
  }

  void _removeMemberName(String name) {
    setState(() {
      _memberNames.remove(name);
    });
  }

  void _increaseCount() {
    setState(() {
      _membersCount += 1;
    });
  }

  void _decreaseCount() {
    if (_membersCount == 0) {
      return;
    }
    setState(() {
      _membersCount -= 1;
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
                child: ExpandableNumberedSection(
                  sectionNumber: '1',
                  title: 'تخصيص البحث',
                  isExpanded: _isSectionExpanded,
                  onHeaderTap: () {
                    setState(() {
                      _isSectionExpanded = !_isSectionExpanded;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppText.bodyMedium(
                        'عدد أفراد المجموعة',
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          LuckyBoxCountActionButton(
                            icon: Icons.add,
                            backgroundColor: context.primaryContainer,
                            iconColor: context.onPrimary,
                            onTap: _increaseCount,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xffF9FAFB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xffE5E7EB),
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: AppText.titleMedium(
                                '$_membersCount',
                                color: const Color(0xff6B7280),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          LuckyBoxCountActionButton(
                            icon: Icons.remove,
                            backgroundColor: const Color(0xffF3F4F6),
                            iconColor: const Color(0xff4B5563),
                            onTap: _decreaseCount,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledTextField(
                        label: 'ميزانية الشخص الواحد',
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
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
                        onTap: _pickRange,
                        suffixIcon: const Icon(Icons.chevron_left),
                      ),
                      const SizedBox(height: 14),
                      FilledTextField(
                        label: 'هل هناك قيود؟',
                        controller: _constraintsController,
                        readOnly: true,
                        onTap: _pickConstraint,
                        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                      const SizedBox(height: 14),
                      FilledTextField(
                        label: 'نوع المطاعم',
                        controller: _restaurantTypeController,
                        readOnly: true,
                        onTap: _pickRestaurantType,
                        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                      const SizedBox(height: 16),
                      AppText.bodyMedium(
                        'أسماء المجموعة',
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _memberNameController,
                              style: const TextStyle(
                                color: Color(0xff2F2B3D),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                hintText: 'اكتب اسم الشخص',
                                hintStyle: const TextStyle(
                                  color: Color(0xff9CA3AF),
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: const Color(0xffF9FAFB),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xffE5E7EB),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xffE5E7EB),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: context.primary,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addMemberName,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryContainer,
                              foregroundColor: context.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 13,
                              ),
                            ),
                            child: AppText.labelLarge(
                              'إضافة',
                              color: context.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (_memberNames.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        LuckyBoxNameTagsWrap(
                          names: _memberNames,
                          onRemoveTap: _removeMemberName,
                        ),
                      ],
                    ],
                  ),
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
                      onPressed: () {
                        context.pushRoute('/rsluckyboxsuggestions');
                      },
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
                        'ابحث عن عرض',
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
