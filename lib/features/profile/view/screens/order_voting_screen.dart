import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/widgets/success_action_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/profile_api_models.dart';
import '../../domain/usecases/create_vote_use_case.dart';
import '../../domain/usecases/fetch_active_votes_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/expandable_numbered_section.dart';
import '../widgets/filled_text_field.dart';
import '../widgets/order_voting_created_poll_item.dart';
import '../widgets/order_voting_created_polls_list.dart';
import '../widgets/order_voting_mode.dart';
import '../widgets/order_voting_mode_switcher.dart';
import '../widgets/order_voting_tag_wrap.dart';
import '../widgets/personal_details_app_bar.dart';
import 'vote_followup_screen.dart';

@AutoRoutePage()
class OrderVotingScreen extends StatelessWidget {
  const OrderVotingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(create: (_) => getIt<ProfileBloc>(), child: const _OrderVotingScreenBody());
  }
}

class _OrderVotingScreenBody extends StatefulWidget {
  const _OrderVotingScreenBody();

  @override
  State<_OrderVotingScreenBody> createState() => _OrderVotingScreenBodyState();
}

class _OrderVotingScreenBodyState extends State<_OrderVotingScreenBody> {
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _suggestionsController = TextEditingController();
  final TextEditingController _restaurantTypeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final FocusNode _mealFocusNode = FocusNode();

  String? _lastCommittedMealQuery;

  OrderVotingMode _mode = OrderVotingMode.create;
  bool _isSectionOneExpanded = true;
  bool _isSectionTwoExpanded = true;

  final List<VoteProductSuggestionModel> _selectedSuggestions = [];
  VoteCuisineTypeModel? _selectedRestaurantType;
  int? _selectedDurationMinutes;

  List<VoteCuisineTypeModel> _restaurantTypes = const <VoteCuisineTypeModel>[];
  List<int> _durations = const <int>[];

  @override
  void initState() {
    super.initState();
    _mealFocusNode.addListener(() {
      if (!_mealFocusNode.hasFocus) {
        _commitMealSearch();
      }
    });
  }

  @override
  void dispose() {
    _mealFocusNode.dispose();
    _mealController.dispose();
    _suggestionsController.dispose();
    _restaurantTypeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _commitMealSearch({bool forceRetry = false}) {
    if (!mounted) return;
    final query = _mealController.text.trim();
    final bloc = context.read<ProfileBloc>();
    final st = bloc.state;
    if (!forceRetry) {
      if (query == _lastCommittedMealQuery && st.voteSuggestionsStatus == BlocStatus.loading) {
        return;
      }
      if (query == _lastCommittedMealQuery && st.voteSuggestionsStatus == BlocStatus.success) {
        return;
      }
    }
    _lastCommittedMealQuery = query;
    bloc.add(FetchVoteSuggestionsEvent(searchQuery: query));
  }

  void _onMealFieldSubmitted() {
    _commitMealSearch();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Ensures suggestions are loaded when opening pickers (e.g. user opens sheet before unfocus).
  void _ensureVoteSuggestionsForPickers() {
    final q = _mealController.text.trim();
    if (q.isEmpty) return;
    if (!mounted) return;
    final st = context.read<ProfileBloc>().state;
    if (q != _lastCommittedMealQuery) {
      _commitMealSearch();
      return;
    }
    if (st.voteSuggestionsStatus == BlocStatus.failed) {
      _commitMealSearch(forceRetry: true);
    }
  }

  Future<void> _pickMultipleSuggestions(ProfileBloc bloc) async {
    if (_mealController.text.trim().isEmpty) {
      _showSnackBar('اكتب ما تود أكله ثم اضغط تم أو اخرج من الحقل');
      return;
    }
    _ensureVoteSuggestionsForPickers();
    final options = await _showSuggestionsBottomSheet(bloc);
    if (!mounted || options == null) return;
    setState(() {
      _selectedSuggestions
        ..clear()
        ..addAll(options);
      _suggestionsController.text = _selectedSuggestions.isEmpty ? '' : 'تم اختيار ${_selectedSuggestions.length}';
    });
  }

  Future<void> _pickRestaurantType(ProfileBloc bloc) async {
    if (_mealController.text.trim().isEmpty) {
      _showSnackBar('اكتب ما تود أكله ثم اضغط تم أو اخرج من الحقل');
      return;
    }
    _ensureVoteSuggestionsForPickers();
    final options = await _showCuisineBottomSheet(bloc);
    if (!mounted || options == null) {
      return;
    }
    final selectedName = options.isEmpty ? null : options.first;
    final types = context.read<ProfileBloc>().state.voteSuggestions?.cuisineTypes ?? const <VoteCuisineTypeModel>[];
    VoteCuisineTypeModel? value;
    for (final type in types) {
      if (type.name == selectedName) {
        value = type;
        break;
      }
    }
    setState(() {
      _selectedRestaurantType = value;
      _restaurantTypeController.text = value?.name ?? '';
    });
  }

  Future<void> _pickDuration(ProfileBloc bloc) async {
    if (_mealController.text.trim().isEmpty) {
      _showSnackBar('اكتب ما تود أكله ثم اضغط تم أو اخرج من الحقل');
      return;
    }
    _ensureVoteSuggestionsForPickers();
    final options = await _showDurationBottomSheet(bloc);
    if (!mounted || options == null) {
      return;
    }
    final value = options.isEmpty ? null : int.tryParse(options.first.split(' ').first);
    setState(() {
      _selectedDurationMinutes = value;
      _durationController.text = value == null ? '' : _durationLabel(value);
    });
  }

  Future<List<VoteProductSuggestionModel>?> _showSuggestionsBottomSheet(ProfileBloc bloc) async {
    final current = <int>{..._selectedSuggestions.map((e) => e.id).whereType<int>()};
    return showModalBottomSheet<List<VoteProductSuggestionModel>>(
      context: context,
      backgroundColor: context.onPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return BlocBuilder<ProfileBloc, ProfileState>(
              bloc: bloc,
              builder: (context, state) {
                final title = AppText.titleMedium('اختر خيارات التصويت', fontWeight: FontWeight.w700, color: context.primary);

                final isLoading = state.voteSuggestionsStatus == null || state.voteSuggestionsStatus == BlocStatus.loading;

                if (isLoading) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 24, 18, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          title,
                          const SizedBox(height: 24),
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          AppText.bodyMedium('جاري تحميل الاقتراحات…', color: const Color(0xff6B7280)),
                        ],
                      ),
                    ),
                  );
                }

                if (state.voteSuggestionsStatus == BlocStatus.failed) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          title,
                          const SizedBox(height: 12),
                          AppText.bodyMedium(state.errorMessage ?? 'تعذر تحميل الاقتراحات', color: const Color(0xff6B7280)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _commitMealSearch(forceRetry: true);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: context.primary,
                              foregroundColor: context.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: AppText.labelLarge('إعادة المحاولة', color: context.onPrimary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final suggestions = state.voteSuggestions?.suggestions ?? const <VoteProductSuggestionModel>[];

                if (suggestions.isEmpty) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          const SizedBox(height: 12),
                          AppText.bodyMedium('لا توجد اقتراحات لهذا البحث', color: const Color(0xff6B7280)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(onPressed: () => Navigator.of(modalContext).pop(), child: const Text('إغلاق')),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final maxListHeight = MediaQuery.sizeOf(context).height * 0.45;

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: maxListHeight),
                          child: ListView(
                            shrinkWrap: true,
                            children: suggestions.map((option) {
                              final optionId = option.id ?? -1;
                              final isSelected = current.contains(optionId);
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: AppText.bodyMedium(_suggestionDisplay(option)),
                                trailing: Checkbox(
                                  value: isSelected,
                                  activeColor: context.primaryContainer,
                                  onChanged: (value) {
                                    setModalState(() {
                                      if (value == true) {
                                        current.add(optionId);
                                      } else {
                                        current.remove(optionId);
                                      }
                                    });
                                  },
                                ),
                                onTap: () {
                                  setModalState(() {
                                    if (isSelected) {
                                      current.remove(optionId);
                                    } else {
                                      current.add(optionId);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final selected = suggestions.where((e) => current.contains(e.id)).toList();
                              Navigator.of(modalContext).pop(selected);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: context.primary,
                              foregroundColor: context.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      },
    );
  }

  Future<Set<String>?> _showCuisineBottomSheet(ProfileBloc bloc) async {
    final current = <String>{if (_selectedRestaurantType?.name != null) _selectedRestaurantType!.name!};
    return showModalBottomSheet<Set<String>>(
      context: context,
      backgroundColor: context.onPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return BlocBuilder<ProfileBloc, ProfileState>(
              bloc: bloc,
              builder: (context, state) {
                final title = AppText.titleMedium('حدد نوع المطعم', fontWeight: FontWeight.w700, color: context.primary);

                final isLoading = state.voteSuggestionsStatus == null || state.voteSuggestionsStatus == BlocStatus.loading;

                if (isLoading) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 24, 18, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          title,
                          const SizedBox(height: 24),
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          AppText.bodyMedium('جاري التحميل…', color: const Color(0xff6B7280)),
                        ],
                      ),
                    ),
                  );
                }

                if (state.voteSuggestionsStatus == BlocStatus.failed) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          title,
                          const SizedBox(height: 12),
                          AppText.bodyMedium(state.errorMessage ?? 'تعذر التحميل', color: const Color(0xff6B7280)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _commitMealSearch(forceRetry: true),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: context.primary,
                              foregroundColor: context.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: AppText.labelLarge('إعادة المحاولة', color: context.onPrimary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final types = state.voteSuggestions?.cuisineTypes ?? const <VoteCuisineTypeModel>[];
                final labels = types.map((e) => e.name ?? '').where((e) => e.isNotEmpty).toList();

                if (labels.isEmpty) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          const SizedBox(height: 12),
                          AppText.bodyMedium('لا توجد أنواع مطاعم', color: const Color(0xff6B7280)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(onPressed: () => Navigator.of(modalContext).pop(), child: const Text('إغلاق')),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final maxListHeight = MediaQuery.sizeOf(context).height * 0.45;

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: maxListHeight),
                          child: ListView(
                            shrinkWrap: true,
                            children: labels.map((option) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: AppText.bodyMedium(option),
                                trailing: Radio<String>(
                                  value: option,
                                  groupValue: current.isEmpty ? null : current.first,
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
                                    current
                                      ..clear()
                                      ..add(option);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
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
      },
    );
  }

  Future<Set<String>?> _showDurationBottomSheet(ProfileBloc bloc) async {
    final current = <String>{if (_selectedDurationMinutes != null) _durationLabel(_selectedDurationMinutes!)};
    return showModalBottomSheet<Set<String>>(
      context: context,
      backgroundColor: context.onPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return BlocBuilder<ProfileBloc, ProfileState>(
              bloc: bloc,
              builder: (context, state) {
                final title = AppText.titleMedium('حدد مدة التصويت', fontWeight: FontWeight.w700, color: context.primary);

                final isLoading = state.voteSuggestionsStatus == null || state.voteSuggestionsStatus == BlocStatus.loading;

                if (isLoading) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 24, 18, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          title,
                          const SizedBox(height: 24),
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          AppText.bodyMedium('جاري التحميل…', color: const Color(0xff6B7280)),
                        ],
                      ),
                    ),
                  );
                }
                if (state.voteSuggestionsStatus == BlocStatus.failed) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          title,
                          const SizedBox(height: 12),
                          AppText.bodyMedium(state.errorMessage ?? 'تعذر التحميل', color: const Color(0xff6B7280)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _commitMealSearch(forceRetry: true),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: context.primary,
                              foregroundColor: context.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: AppText.labelLarge('إعادة المحاولة', color: context.onPrimary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final presets = state.voteSuggestions?.durationMinutesPresets ?? const <int>[];
                final labels = presets.map(_durationLabel).toList();

                if (labels.isEmpty) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          const SizedBox(height: 12),
                          AppText.bodyMedium('لا توجد مدات متاحة', color: const Color(0xff6B7280)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(onPressed: () => Navigator.of(modalContext).pop(), child: const Text('إغلاق')),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final maxListHeight = MediaQuery.sizeOf(context).height * 0.45;

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: maxListHeight),
                          child: ListView(
                            shrinkWrap: true,
                            children: labels.map((option) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: AppText.bodyMedium(option),
                                trailing: Radio<String>(
                                  value: option,
                                  groupValue: current.isEmpty ? null : current.first,
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
                                    current
                                      ..clear()
                                      ..add(option);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
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
      },
    );
  }

  void _removeSuggestionChip(String value) {
    setState(() {
      _selectedSuggestions.removeWhere((e) => _suggestionDisplay(e) == value);
      if (_selectedSuggestions.isEmpty) {
        _suggestionsController.clear();
      } else {
        _suggestionsController.text = 'تم اختيار ${_selectedSuggestions.length}';
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _durationLabel(int minutes) => '$minutes دقيقة';

  String _suggestionDisplay(VoteProductSuggestionModel item) {
    final name = item.name ?? '';
    final restaurant = item.restaurantName ?? '';
    if (restaurant.isEmpty) return name;
    return '$name - $restaurant';
  }

  void _syncSuggestionsFromState(ProfileState state) {
    final incoming = state.voteSuggestions;
    if (incoming == null) return;
    final validIds = incoming.suggestions.map((e) => e.id).whereType<int>().toSet();
    setState(() {
      _durations = incoming.durationMinutesPresets;
      _restaurantTypes = incoming.cuisineTypes;
      _selectedSuggestions.removeWhere((e) {
        final id = e.id;
        return id == null || !validIds.contains(id);
      });
      if (_selectedSuggestions.isEmpty) {
        _suggestionsController.clear();
      } else {
        _suggestionsController.text = 'تم اختيار ${_selectedSuggestions.length}';
      }
      if (_selectedRestaurantType != null && !_restaurantTypes.any((e) => e.id == _selectedRestaurantType!.id)) {
        _selectedRestaurantType = null;
        _restaurantTypeController.clear();
      }
      if (_selectedDurationMinutes != null && !_durations.contains(_selectedDurationMinutes)) {
        _selectedDurationMinutes = null;
        _durationController.clear();
      }
    });
  }

  void _createVoteAndContinue() {
    if (_selectedSuggestions.length < 2) {
      _showSnackBar('يرجى اختيار خيارين على الأقل لإنشاء التصويت');
      return;
    }
    context.read<ProfileBloc>().add(
      CreateVoteEvent(
        params: CreateVoteParams(
          durationMinutes: _selectedDurationMinutes ?? 30,
          foodCategoryHint: _mealController.text.trim().isEmpty ? null : _mealController.text.trim(),
          cuisineTypeId: _selectedRestaurantType?.id,
          options: _selectedSuggestions.map((e) => {'label': e.name ?? '', 'productId': e.id}).toList(),
        ),
      ),
    );
  }

  List<OrderVotingCreatedPollItem> _mapActiveVotesToPollItems(List<VoteCreatedData> activeVotes) {
    return activeVotes.where((e) => e.vote?.id != null).map((entry) {
      final vote = entry.vote!;
      final title = (vote.foodCategoryHint ?? '').trim().isNotEmpty ? vote.foodCategoryHint!.trim() : 'تصويت #${vote.id}';
      final detailParts = <String>['${entry.options.length} خيارات', _remainingLabel(vote.secondsRemaining)];
      return OrderVotingCreatedPollItem(title: title, detail: detailParts.join(' • '), voteId: vote.id!, initialData: entry);
    }).toList();
  }

  String _remainingLabel(int? secondsRemaining) {
    if (secondsRemaining == null || secondsRemaining <= 0) {
      return 'ينتهي قريبًا';
    }
    if (secondsRemaining < 60) {
      return '$secondsRemaining ثانية متبقية';
    }
    final minutes = secondsRemaining ~/ 60;
    return '$minutes دقيقة متبقية';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.createVoteStatus != current.createVoteStatus ||
          previous.voteSuggestionsStatus != current.voteSuggestionsStatus ||
          previous.activeVotesStatus != current.activeVotesStatus ||
          previous.voteSuggestions != current.voteSuggestions,
      listener: (context, state) {
        if (state.voteSuggestionsStatus == BlocStatus.failed && state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          _showSnackBar(state.errorMessage!);
        }
        if (state.voteSuggestionsStatus == BlocStatus.success) {
          _syncSuggestionsFromState(state);
        }
        if (state.createVoteStatus == BlocStatus.failed && state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          _showSnackBar(state.errorMessage!);
          return;
        }
        if (state.activeVotesStatus == BlocStatus.failed && state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          _showSnackBar(state.errorMessage!);
          return;
        }
        // Add SuccessActionBottomSheet for createVoteStatus success
        if (state.createVoteStatus == BlocStatus.success && _mode == OrderVotingMode.create) {
          final createdVote = state.createdVote;
          final voteId = createdVote?.voteId;
          if (createdVote?.data == null || voteId == null) {
            _showSnackBar('تعذر إنشاء التصويت');
            return;
          }
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) {
              return SuccessActionBottomSheet(
                title: 'تم إنشاء التصويت',
                followUpLabel: 'متابعة التصويت',
                shareLabel: 'مشاركة',
                onFollowUp: () {
                  Navigator.of(context).pop();
                  context.pushRoute(
                    '/votefollowup',
                    arguments: VoteFollowupScreenParams(voteId: voteId, initialData: createdVote!.data),
                  );
                },
                onShare: () {
                  Navigator.of(context).pop();
                  context.pushRoute(
                    '/votefollowup',
                    arguments: VoteFollowupScreenParams(voteId: voteId, initialData: createdVote!.data, needShare: true),
                  );
                },
              );
            },
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF9FAFB),
        body: SafeArea(
          child: Column(
            children: [
              const PersonalDetailsAppBar(title: 'التصويت على الطلب'),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      OrderVotingModeSwitcher(
                        mode: _mode,
                        onModeChanged: (mode) {
                          if (_mode == mode) {
                            return;
                          }
                          setState(() {
                            _mode = mode;
                          });
                          if (mode == OrderVotingMode.existingPolls) {
                            context.read<ProfileBloc>().add(FetchActiveVotesEvent(params: FetchActiveVotesParams()));
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_mode == OrderVotingMode.create) ...[
                        ExpandableNumberedSection(
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
                              AppText.headlineMedium('اكتب ما تود أكله اليوم', color: const Color(0xff374151)),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _mealController,
                                focusNode: _mealFocusNode,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _onMealFieldSubmitted(),
                                onEditingComplete: _onMealFieldSubmitted,
                                style: const TextStyle(color: Color(0xff2F2B3D), fontSize: 14, fontWeight: FontWeight.w400),
                                decoration: InputDecoration(
                                  hintText: 'مثال: برغر',
                                  hintStyle: const TextStyle(color: Color(0xff9CA3AF), fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xffD1D5DB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xffD1D5DB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: context.primary, width: 1.2),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xffF9FAFB),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ExpandableNumberedSection(
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
                              BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, state) {
                                  return FilledTextField(
                                    label: 'اقتراحات النظام',
                                    controller: _suggestionsController,
                                    readOnly: true,
                                    onTap: () {
                                      _pickMultipleSuggestions(context.read<ProfileBloc>());
                                    },
                                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              if (_selectedSuggestions.isNotEmpty) ...[
                                OrderVotingTagWrap(values: _selectedSuggestions.map(_suggestionDisplay).toList(), onRemoveTap: _removeSuggestionChip),
                                const SizedBox(height: 14),
                              ],
                              BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, state) {
                                  return FilledTextField(
                                    label: 'نوع المطعم',
                                    controller: _restaurantTypeController,
                                    readOnly: true,
                                    onTap: () {
                                      _pickRestaurantType(context.read<ProfileBloc>());
                                    },
                                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                              BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, state) {
                                  return FilledTextField(
                                    label: 'مدة التصويت',
                                    controller: _durationController,
                                    readOnly: true,
                                    onTap: () {
                                      _pickDuration(context.read<ProfileBloc>());
                                    },
                                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              if (_selectedDurationMinutes != null)
                                OrderVotingTagWrap(
                                  values: [_durationLabel(_selectedDurationMinutes!)],
                                  onRemoveTap: (_) {
                                    setState(() {
                                      _selectedDurationMinutes = null;
                                      _durationController.clear();
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ] else ...[
                        BlocBuilder<ProfileBloc, ProfileState>(
                          buildWhen: (previous, current) =>
                              previous.activeVotesStatus != current.activeVotesStatus || previous.activeVotes != current.activeVotes,
                          builder: (context, state) {
                            if (state.activeVotesStatus == BlocStatus.loading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            if (state.activeVotesStatus == BlocStatus.failed) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    AppText.bodyMedium(state.errorMessage ?? 'تعذر تحميل المقارنات القائمة', color: const Color(0xff6B7280)),
                                    const SizedBox(height: 12),
                                    OutlinedButton(
                                      onPressed: () {
                                        context.read<ProfileBloc>().add(FetchActiveVotesEvent(params: FetchActiveVotesParams()));
                                      },
                                      child: const Text('إعادة المحاولة'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final items = _mapActiveVotesToPollItems(state.activeVotes);
                            if (items.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: AppText.bodyMedium('لا توجد مقارنات قائمة حالياً', color: const Color(0xff6B7280)),
                              );
                            }

                            return OrderVotingCreatedPollsList(
                              items: items,
                              onPollTap: (item) {
                                context.pushRoute(
                                  '/votefollowup',
                                  arguments: VoteFollowupScreenParams(voteId: item.voteId, initialData: item.initialData),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_mode == OrderVotingMode.create)
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: BlocBuilder<ProfileBloc, ProfileState>(
                          buildWhen: (previous, current) => previous.createVoteStatus != current.createVoteStatus,
                          builder: (context, state) {
                            final isCreating = state.createVoteStatus == BlocStatus.loading;
                            return ElevatedButton(
                              onPressed: isCreating ? null : _createVoteAndContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primary,
                                foregroundColor: context.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: isCreating
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : AppText.labelLarge('إنشاء التصويت', color: context.onPrimary, fontWeight: FontWeight.w700),
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
      ),
    );
  }
}
