import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/luck_box_api_models.dart';
import '../../domain/services/user_location_service.dart';
import '../manager/lucky_box_cubit.dart';
import '../widgets/expandable_numbered_section.dart';
import '../widgets/filled_text_field.dart';
import '../widgets/lucky_box_count_action_button.dart';
import '../widgets/personal_details_app_bar.dart';
import 'lucky_box_suggestions_args.dart';

@AutoRoutePage()
class LuckyBoxSetupScreen extends StatelessWidget {
  const LuckyBoxSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<LuckyBoxCubit>()..loadOptions(), child: const _LuckyBoxSetupBody());
  }
}

class _LuckyBoxSetupBody extends StatefulWidget {
  const _LuckyBoxSetupBody();

  @override
  State<_LuckyBoxSetupBody> createState() => _LuckyBoxSetupBodyState();
}

class _LuckyBoxSetupBodyState extends State<_LuckyBoxSetupBody> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _constraintsController = TextEditingController(text: 'لا قيود');
  final TextEditingController _restaurantTypeController = TextEditingController(text: 'الكل');

  bool _isSectionExpanded = true;
  int _membersCount = 0;
  final Set<String> _selectedRestrictionValues = {};
  int? _selectedCuisineId;

  @override
  void dispose() {
    _budgetController.dispose();
    _constraintsController.dispose();
    _restaurantTypeController.dispose();
    super.dispose();
  }

  void _syncConstraintFieldText(LuckBoxOptionsModel? options) {
    if (options == null) return;
    if (_selectedRestrictionValues.isEmpty) {
      _constraintsController.text = 'لا قيود';
      return;
    }
    final labels = options.restrictions
        .where((r) => r.value != null && _selectedRestrictionValues.contains(r.value))
        .map((r) => r.labelAr ?? r.value ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    _constraintsController.text = labels.join('، ');
  }

  void _syncCuisineFieldText(LuckBoxOptionsModel? options) {
    if (_selectedCuisineId == null || options == null) {
      _restaurantTypeController.text = 'الكل';
      return;
    }
    LuckBoxCuisineTypeOption? match;
    for (final c in options.cuisineTypes) {
      if (c.id == _selectedCuisineId) {
        match = c;
        break;
      }
    }
    final name = match?.name?.trim();
    _restaurantTypeController.text = name != null && name.isNotEmpty ? name : 'الكل';
  }

  Future<void> _pickRestrictions(LuckBoxOptionsModel options) async {
    final initial = Set<String>.from(_selectedRestrictionValues);
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      backgroundColor: context.onPrimary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (modalContext) {
        var working = Set<String>.from(initial);
        return StatefulBuilder(
          builder: (_, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.titleMedium('هل هناك قيود؟', fontWeight: FontWeight.w700, color: context.primary),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.45),
                      child: SingleChildScrollView(
                        child: Column(
                          children: options.restrictions.map((r) {
                            final v = r.value;
                            if (v == null) return const SizedBox.shrink();
                            final checked = working.contains(v);
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: AppText.bodyMedium(r.labelAr ?? v),
                              value: checked,
                              activeColor: context.primaryContainer,
                              onChanged: (on) {
                                setModalState(() {
                                  if (on == true) {
                                    working.add(v);
                                  } else {
                                    working.remove(v);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(modalContext).pop(working),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: context.primary,
                          foregroundColor: context.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: AppText.labelLarge('تأكيد', color: context.onPrimary, fontWeight: FontWeight.w700),
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
    if (!mounted || result == null) return;
    setState(() {
      _selectedRestrictionValues
        ..clear()
        ..addAll(result);
      _syncConstraintFieldText(options);
    });
  }

  Future<void> _pickCuisine(LuckBoxOptionsModel options) async {
    int? current = _selectedCuisineId;
    final picked = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: context.onPrimary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                    AppText.titleMedium('نوع المطاعم', fontWeight: FontWeight.w700, color: context.primary),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: AppText.bodyMedium('الكل'),
                      trailing: Radio<int?>(
                        value: null,
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
                          current = null;
                        });
                      },
                    ),
                    ...options.cuisineTypes.map((c) {
                      final id = c.id;
                      if (id == null) return const SizedBox.shrink();
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: AppText.bodyMedium(c.name ?? ''),
                        trailing: Radio<int?>(
                          value: id,
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
                            current = id;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(modalContext).pop(current),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: context.primary,
                          foregroundColor: context.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: AppText.labelLarge('تأكيد', color: context.onPrimary, fontWeight: FontWeight.w700),
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
    if (!mounted) return;
    setState(() {
      _selectedCuisineId = picked;
      _syncCuisineFieldText(context.read<LuckyBoxCubit>().state.options);
    });
  }

  Future<void> _onSearchPressed() async {
    final budgetRaw = _budgetController.text.trim();
    final budget = int.tryParse(budgetRaw);
    if (_membersCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تحديد عدد أفراد المجموعة')));
      return;
    }
    if (budget == null || budget < 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال ميزانية صحيحة للشخص الواحد')));
      return;
    }

    final cubit = context.read<LuckyBoxCubit>();
    Loading.show(context);
    final loc = await getIt<UserLocationService>().getCurrentPosition();
    if (!mounted) return;
    if (loc.latitude == null || loc.longitude == null) {
      Loading.close();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: AppText('يرجى تفعيل الموقع ومنح التطبيق الإذن لتحديد موقعك قبل البحث'), backgroundColor: Colors.red));
      return;
    }

    final params = SuggestLuckBoxParams(
      groupSize: _membersCount,
      budgetPerPerson: budget,
      restrictions: _selectedRestrictionValues.toList(),
      latitude: loc.latitude,
      longitude: loc.longitude,
      cuisineTypeId: _selectedCuisineId,
    );
    await cubit.suggestLuckBox(params);
    if (!mounted) return;
    Loading.close();

    final st = cubit.state;
    if (st.suggestStatus == BlocStatus.success && st.suggestResult != null) {
      final options = st.options;
      final constraintsSummary = _selectedRestrictionValues.isEmpty
          ? 'لا قيود'
          : (options == null
                ? _constraintsController.text
                : options.restrictions
                      .where((r) => r.value != null && _selectedRestrictionValues.contains(r.value))
                      .map((r) => r.labelAr ?? r.value ?? '')
                      .where((s) => s.isNotEmpty)
                      .join('، '));
      final args = LuckyBoxSuggestionsArgs(
        groupSize: _membersCount,
        budgetPerPerson: budget,
        restrictionValues: _selectedRestrictionValues.toList(),
        cuisineTypeId: _selectedCuisineId,
        initialResponse: st.suggestResult!,
        budgetSummaryText: '$budget ل.س',
        constraintsSummaryText: constraintsSummary,
        cuisineSummaryText: _restaurantTypeController.text,
      );
      cubit.clearSuggestStatus();
      context.pushRoute('/luckyboxsuggestions', arguments: args);
    } else if (st.suggestStatus == BlocStatus.failed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(st.errorMessage ?? 'تعذر جلب الاقتراحات')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LuckyBoxCubit, LuckyBoxState>(
      listenWhen: (p, c) => c.optionsStatus == BlocStatus.failed && p.optionsStatus != BlocStatus.failed,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        final options = state.options;

        final optionsLoading = state.optionsStatus == BlocStatus.loading || state.optionsStatus == null;
        final optionsFailed = state.optionsStatus == BlocStatus.failed;
        final canPick = state.optionsStatus == BlocStatus.success && options != null;

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
                          if (optionsLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (optionsFailed)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OutlinedButton(
                                onPressed: () => context.read<LuckyBoxCubit>().loadOptions(),
                                child: const Text('إعادة تحميل الخيارات'),
                              ),
                            ),
                          AppText.bodyMedium('عدد أفراد المجموعة', fontWeight: FontWeight.w600, textAlign: TextAlign.center),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              LuckyBoxCountActionButton(
                                icon: Icons.add,
                                backgroundColor: context.primaryContainer,
                                iconColor: context.onPrimary,
                                onTap: () {
                                  setState(() {
                                    _membersCount += 1;
                                  });
                                },
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF9FAFB),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xffE5E7EB), width: 1),
                                  ),
                                  alignment: Alignment.center,
                                  child: AppText.titleMedium('$_membersCount', color: const Color(0xff6B7280), fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 10),
                              LuckyBoxCountActionButton(
                                icon: Icons.remove,
                                backgroundColor: const Color(0xffF3F4F6),
                                iconColor: const Color(0xff4B5563),
                                onTap: () {
                                  if (_membersCount == 0) return;
                                  setState(() {
                                    _membersCount -= 1;
                                  });
                                },
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
                              child: Center(widthFactor: 1, child: AppText.bodyMedium('ل.س', color: const Color(0xff9CA3AF))),
                            ),
                          ),
                          const SizedBox(height: 14),
                          FilledTextField(
                            label: 'هل هناك قيود؟',
                            controller: _constraintsController,
                            readOnly: true,
                            onTap: !canPick ? null : () => _pickRestrictions(options),
                            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                          const SizedBox(height: 14),
                          FilledTextField(
                            label: 'نوع المطاعم',
                            controller: _restaurantTypeController,
                            readOnly: true,
                            onTap: !canPick ? null : () => _pickCuisine(options),
                            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                          ),
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
                          onPressed: optionsLoading ? null : _onSearchPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primary,
                            foregroundColor: context.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: AppText.labelLarge('ابحث عن عرض', color: context.onPrimary, fontWeight: FontWeight.w700),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: AppText.labelLarge('إلغاء', color: context.error, fontWeight: FontWeight.w600),
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
      },
    );
  }
}
