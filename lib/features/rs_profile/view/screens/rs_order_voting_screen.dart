import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_vote_use_case.dart';
import '../manager/bloc/rs_profile_bloc.dart';
import '../widgets/rs_expandable_numbered_section.dart';
import '../widgets/rs_filled_text_field.dart';
import '../widgets/rs_order_voting_success_dialog.dart';
import '../widgets/rs_personal_details_app_bar.dart';

enum _VotingMode { create, existingPolls }

@AutoRoutePage()
class RsOrderVotingScreen extends StatefulWidget {
  const RsOrderVotingScreen({super.key});

  @override
  State<RsOrderVotingScreen> createState() => _RsOrderVotingScreenState();
}

class _RsOrderVotingScreenState extends State<RsOrderVotingScreen> {
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _suggestionsController = TextEditingController();
  final TextEditingController _restaurantTypeController =
      TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  _VotingMode _mode = _VotingMode.create;
  bool _isSectionOneExpanded = true;
  bool _isSectionTwoExpanded = true;

  final List<String> _selectedSuggestions = [];
  String? _selectedRestaurantType;
  String? _selectedDuration;

  final List<String> _suggestionOptions = const [
    'برغر دبل جبنة',
    'بيتزا سيخ',
    'برغر دبل',
    'مندي دجاج',
  ];
  final List<String> _restaurantTypes = const [
    'مشاوي',
    'وجبات سريعة',
    'بيتزا',
    'شرقي',
  ];
  final List<String> _durations = const [
    '15 دقيقة',
    '30 دقيقة',
    '45 دقيقة',
    '60 دقيقة',
  ];
  static const List<_CreatedPollItem> _createdPolls = [];

  @override
  void dispose() {
    _mealController.dispose();
    _suggestionsController.dispose();
    _restaurantTypeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickMultipleSuggestions() async {
    final options = await _showOptionsBottomSheet(
      title: 'اختر ما يعجبك',
      options: _suggestionOptions,
      selectedOptions: _selectedSuggestions.toSet(),
      allowMultiple: true,
    );
    if (!mounted || options == null) {
      return;
    }
    setState(() {
      _selectedSuggestions
        ..clear()
        ..addAll(options);
      _suggestionsController.text = _selectedSuggestions.isEmpty
          ? ''
          : 'تم اختيار ${_selectedSuggestions.length}';
    });
  }

  Future<void> _pickRestaurantType() async {
    final options = await _showOptionsBottomSheet(
      title: 'حدد نوع المطعم',
      options: _restaurantTypes,
      selectedOptions: {
        if (_selectedRestaurantType != null) _selectedRestaurantType!,
      },
      allowMultiple: false,
    );
    if (!mounted || options == null) {
      return;
    }
    final value = options.isEmpty ? null : options.first;
    setState(() {
      _selectedRestaurantType = value;
      _restaurantTypeController.text = value ?? '';
    });
  }

  Future<void> _pickDuration() async {
    final options = await _showOptionsBottomSheet(
      title: 'حدد مدة التصويت',
      options: _durations,
      selectedOptions: {if (_selectedDuration != null) _selectedDuration!},
      allowMultiple: false,
    );
    if (!mounted || options == null) {
      return;
    }
    final value = options.isEmpty ? null : options.first;
    setState(() {
      _selectedDuration = value;
      _durationController.text = value ?? '';
    });
  }

  Future<Set<String>?> _showOptionsBottomSheet({
    required String title,
    required List<String> options,
    required Set<String> selectedOptions,
    required bool allowMultiple,
  }) async {
    final current = <String>{...selectedOptions};
    return showModalBottomSheet<Set<String>>(
      context: context,
      backgroundColor: context.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
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
                      final isSelected = current.contains(option);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: AppText.bodyMedium(option),
                        trailing: allowMultiple
                            ? Checkbox(
                                value: isSelected,
                                activeColor: context.primaryContainer,
                                onChanged: (value) {
                                  setModalState(() {
                                    if (value == true) {
                                      current.add(option);
                                    } else {
                                      current.remove(option);
                                    }
                                  });
                                },
                              )
                            : Radio<String>(
                                value: option,
                                groupValue: current.isEmpty
                                    ? null
                                    : current.first,
                                activeColor: context.primaryContainer,
                                onChanged: (value) {
                                  setModalState(() {
                                    current
                                      ..clear()
                                      ..addAll(value == null ? [] : [value]);
                                  });
                                },
                              ),
                        onTap: () {
                          setModalState(() {
                            if (allowMultiple) {
                              if (isSelected) {
                                current.remove(option);
                              } else {
                                current.add(option);
                              }
                            } else {
                              current
                                ..clear()
                                ..add(option);
                            }
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

  void _removeSuggestionChip(String value) {
    setState(() {
      _selectedSuggestions.remove(value);
      if (_selectedSuggestions.isEmpty) {
        _suggestionsController.clear();
      } else {
        _suggestionsController.text =
            'تم اختيار ${_selectedSuggestions.length}';
      }
    });
  }

  void _showCreateSuccessDialog(int voteId) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return RsOrderVotingSuccessDialog(
          onContinueTap: () {
            Navigator.of(context).pop();
            context.pushRoute('/rsvotefollowup', arguments: voteId);
          },
          onShareTap: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ميزة المشاركة ستكون متاحة قريباً')),
            );
          },
        );
      },
    );
  }

  void _createVoteAndContinue() {
    context.read<RsProfileBloc>().add(
      CreateVoteEvent(
        params: CreateVoteParams(
          durationMinutes: _selectedDuration == null
              ? 30
              : int.tryParse(_selectedDuration!.split(' ').first) ?? 30,
          foodCategoryHint: _mealController.text.trim().isEmpty
              ? null
              : _mealController.text.trim(),
          options: _selectedSuggestions.isEmpty
              ? [
                  {'label': 'Option A', 'productId': null},
                  {'label': 'Option B', 'productId': null},
                ]
              : _selectedSuggestions
                    .map((e) => {'label': e, 'productId': null})
                    .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RsProfileBloc>(
      create: (_) => getIt<RsProfileBloc>(),
      child: BlocListener<RsProfileBloc, RsProfileState>(
        listenWhen: (previous, current) =>
            previous.createVoteStatus != current.createVoteStatus,
        listener: (context, state) {
          if (state.createVoteStatus == BlocStatus.failed &&
              state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            return;
          }
          if (state.createVoteStatus == BlocStatus.success) {
            final voteId = state.createdVote?.voteId;
            if (voteId == null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تعذر إنشاء التصويت')));
              return;
            }
            _showCreateSuccessDialog(voteId);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                const RsPersonalDetailsAppBar(title: 'التصويت على الطلب'),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        _ModeSwitcher(
                          mode: _mode,
                          onModeChanged: (mode) {
                            setState(() {
                              _mode = mode;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_mode == _VotingMode.create) ...[
                          RsExpandableNumberedSection(
                            sectionNumber: '1',
                            title: 'ماذا سنأكل اليوم؟',
                            isExpanded: _isSectionOneExpanded,
                            onHeaderTap: () {
                              setState(() {
                                _isSectionOneExpanded = !_isSectionOneExpanded;
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.headlineMedium(
                                  'اكتب ما تود أكله اليوم',
                                  color: const Color(0xff374151),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _mealController,
                                  style: const TextStyle(
                                    color: Color(0xff2F2B3D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'مثال: برغر',
                                    hintStyle: const TextStyle(
                                      color: Color(0xff9CA3AF),
                                      fontSize: 14,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xffD1D5DB),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xffD1D5DB),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: context.primary,
                                        width: 1.2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xffF9FAFB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          RsExpandableNumberedSection(
                            sectionNumber: '2',
                            title: 'خيارات إضافية',
                            isExpanded: _isSectionTwoExpanded,
                            onHeaderTap: () {
                              setState(() {
                                _isSectionTwoExpanded = !_isSectionTwoExpanded;
                              });
                            },
                            child: Column(
                              children: [
                                RsFilledTextField(
                                  label: 'اقتراحات النظام',
                                  controller: _suggestionsController,
                                  readOnly: true,
                                  onTap: _pickMultipleSuggestions,
                                  suffixIcon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (_selectedSuggestions.isNotEmpty) ...[
                                  _TagWrap(
                                    values: _selectedSuggestions,
                                    onRemoveTap: _removeSuggestionChip,
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                RsFilledTextField(
                                  label: 'نوع المطعم',
                                  controller: _restaurantTypeController,
                                  readOnly: true,
                                  onTap: _pickRestaurantType,
                                  suffixIcon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                RsFilledTextField(
                                  label: 'مدة التصويت',
                                  controller: _durationController,
                                  readOnly: true,
                                  onTap: _pickDuration,
                                  suffixIcon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (_selectedDuration != null)
                                  _TagWrap(
                                    values: [_selectedDuration!],
                                    onRemoveTap: (_) {
                                      setState(() {
                                        _selectedDuration = null;
                                        _durationController.clear();
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ] else ...[
                          _CreatedPollsList(
                            items: _createdPolls,
                            onPollTap: (_) {
                              context.pushRoute('/rsvotefollowup', arguments: 1);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_mode == _VotingMode.create)
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: BlocBuilder<RsProfileBloc, RsProfileState>(
                            buildWhen: (previous, current) =>
                                previous.createVoteStatus != current.createVoteStatus,
                            builder: (context, state) {
                              final isCreating =
                                  state.createVoteStatus == BlocStatus.loading;
                              return ElevatedButton(
                                onPressed:
                                    isCreating ? null : _createVoteAndContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primary,
                                  foregroundColor: context.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: isCreating
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : AppText.labelLarge(
                                        'إنشاء التصويت',
                                        color: context.onPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                              );
                            },
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
        ),
      ),
    );
  }
}

class _CreatedPollItem {
  const _CreatedPollItem({required this.title, required this.detail});

  final String title;
  final String detail;
}

class _CreatedPollsList extends StatelessWidget {
  const _CreatedPollsList({required this.items, required this.onPollTap});

  final List<_CreatedPollItem> items;
  final void Function(_CreatedPollItem item) onPollTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText.titleMedium(
          'المقارنات القائمة',
          color: const Color(0xff374151),
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 10),
            child: Material(
              color: context.onPrimary,
              elevation: 2,
              shadowColor: Colors.black.withAlpha(18),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => onPollTap(item),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 12, 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.primaryContainer.withAlpha(40),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.how_to_vote_outlined,
                          color: context.primaryContainer,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.bodyMedium(
                              item.title,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff1F2937),
                            ),
                            const SizedBox(height: 4),
                            AppText.labelLarge(
                              item.detail,
                              color: const Color(0xff6B7280),
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({required this.mode, required this.onModeChanged});

  final _VotingMode mode;
  final ValueChanged<_VotingMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              title: 'المقارنات القائمة',
              isActive: mode == _VotingMode.existingPolls,
              onTap: () => onModeChanged(_VotingMode.existingPolls),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ModeButton(
              title: 'إنشاء التصويت',
              isActive: mode == _VotingMode.create,
              onTap: () => onModeChanged(_VotingMode.create),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isActive ? context.primary : context.onPrimary,
        ),
        child: AppText.labelLarge(
          title,
          textAlign: TextAlign.center,
          color: isActive ? context.onPrimary : const Color(0xff6B7280),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TagWrap extends StatelessWidget {
  const _TagWrap({required this.values, required this.onRemoveTap});

  final List<String> values;
  final ValueChanged<String> onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: values.map((value) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xffFFEDD5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => onRemoveTap(value),
                  child: const CircleAvatar(
                    radius: 7,
                    backgroundColor: Color(0xff92400E),
                    child: Icon(Icons.close, size: 10, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 6),
                AppText.labelLarge(
                  value,
                  color: const Color(0xffB45309),
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
