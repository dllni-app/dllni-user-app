import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../domain/usecases/get_cleaning_services_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/cl_home_description_title_card_widget.dart';
import '../widgets/cl_main_continue_button_widget.dart';
import '../widgets/cl_selectable_menu_field_widget.dart';
import '../widgets/home_details_app_bar.dart';

class _MenuOption {
  final String id;
  final String label;
  final int? serviceId;

  const _MenuOption({required this.id, required this.label, this.serviceId});
}

@AutoRoutePage()
class ClMainOccasionDescriptionScreen extends StatefulWidget {
  const ClMainOccasionDescriptionScreen({this.args, super.key});

  final ClMainOccasionDescriptionArgs? args;

  @override
  State<ClMainOccasionDescriptionScreen> createState() =>
      _ClMainOccasionDescriptionScreenState();
}

class _ClMainOccasionDescriptionScreenState
    extends State<ClMainOccasionDescriptionScreen> {
  static const List<_MenuOption> _specialRequirementOptions = <_MenuOption>[
    _MenuOption(id: 'none', label: 'لا يوجد'),
    _MenuOption(id: 'quick_setup', label: 'تجهيز سريع قبل المناسبة'),
    _MenuOption(id: 'extra_attention', label: 'عناية إضافية لمنطقة الضيافة'),
    _MenuOption(id: 'separate_teams', label: 'توزيع فريق العمل على أقسام'),
  ];

  final TextEditingController _notesController = TextEditingController();
  int _guestsCount = 15;
  bool _enableNotes = false;
  ClMainOccasionDescriptionArgs? _routeArgs;
  ClMainBloc? _bloc;
  bool _didReadArgs = false;
  _MenuOption? _selectedHelpType;
  _MenuOption? _selectedSpecialRequirement;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    _didReadArgs = true;

    final args = widget.args ?? ModalRoute.of(context)?.settings.arguments;
    if (args is ClMainOccasionDescriptionArgs) {
      _routeArgs = args;
      _bloc = args.bloc;
    }
    _bloc?.add(
      GetCleaningServicesEvent(
        params: GetCleaningServicesParams(category: 'event_assisent'),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _eventTypeFromOption(ClMainOccasionOption option) {
    switch (option.id) {
      case 'family_dinner':
        return 'family_dinner';
      case 'birthday_party':
        return 'birthday';
      case 'large_gathering':
        return 'large_gathering';
      case 'condolences':
        return 'funeral';
      default:
        return 'other';
    }
  }

  Future<_MenuOption?> _showOptionsBottomSheet({
    required String title,
    required List<_MenuOption> options,
    _MenuOption? currentValue,
  }) {
    return showModalBottomSheet<_MenuOption>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyLarge(
                  title,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E2A78),
                ),
                const SizedBox(height: 12),
                ...options.map(
                  (option) => ListTile(
                    key: Key('menu_option_${option.id}'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: AppText.bodyMedium(
                      option.label,
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                    ),
                    trailing: Radio<String>(
                      value: option.id,
                      groupValue: currentValue?.id,
                      onChanged: (_) => Navigator.of(ctx).pop(option),
                      activeColor: const Color(0xFF11B9C8),
                    ),
                    onTap: () => Navigator.of(ctx).pop(option),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectHelpType(List<_MenuOption> serviceOptions) async {
    if (serviceOptions.isEmpty) return;
    final value = await _showOptionsBottomSheet(
      title: 'ما هي طبيعة المساعدة المطلوبة؟',
      options: serviceOptions,
      currentValue: _selectedHelpType,
    );
    if (!mounted || value == null) return;
    setState(() {
      _selectedHelpType = value;
    });
  }

  Future<void> _selectSpecialRequirement() async {
    final value = await _showOptionsBottomSheet(
      title: 'هل لديك أي متطلبات خاصة؟',
      options: _specialRequirementOptions,
      currentValue: _selectedSpecialRequirement,
    );
    if (!mounted || value == null) return;
    setState(() {
      _selectedSpecialRequirement = value;
    });
  }

  void _onContinue(ClMainBloc bloc) {
    final args = _routeArgs;
    if (args == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحميل بيانات المناسبة')),
      );
      return;
    }
    if (_selectedHelpType == null || _selectedHelpType?.serviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار طبيعة المساعدة المطلوبة')),
      );
      return;
    }
    if (_selectedSpecialRequirement == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المتطلبات الخاصة')),
      );
      return;
    }

    final eventType = _eventTypeFromOption(args.option);
    final specialRequirement = _selectedSpecialRequirement!.id == 'none'
        ? null
        : _selectedSpecialRequirement!.label;

    bloc.add(
      EstimateCleaningPriceEvent(
        params: EstimateCleaningPriceParams.eventAssistance(
          eventType: eventType,
          guestCount: _guestsCount,
          venueType: 'apartment',
          serviceIds: <int>[_selectedHelpType!.serviceId!],
          specialRequirement: specialRequirement,
          notes: _enableNotes ? _notesController.text.trim() : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _bloc;
    if (bloc == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    final occasionTitle = _routeArgs?.option.title ?? 'المناسبة';

    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<ClMainBloc, ClMainState>(
        listenWhen: (previous, current) =>
            previous.estimatePriceStatus != current.estimatePriceStatus,
        listener: (context, state) {
          if (state.estimatePriceStatus == BlocStatus.loading) return;
          if (state.estimatePriceStatus == BlocStatus.success &&
              state.estimatePrice != null &&
              _routeArgs != null &&
              _selectedHelpType != null &&
              _selectedSpecialRequirement != null) {
            final eventType = _eventTypeFromOption(_routeArgs!.option);
            final specialRequirement = _selectedSpecialRequirement!.id == 'none'
                ? null
                : _selectedSpecialRequirement!.label;
            context.pushRoute(
              '/clmainoccasionschedule',
              arguments: ClMainOccasionScheduleArgs(
                option: _routeArgs!.option,
                bloc: bloc,
                estimate: state.estimatePrice!,
                guestsCount: _guestsCount,
                eventType: eventType,
                venueType: 'apartment',
                serviceIds: <int>[_selectedHelpType!.serviceId!],
                suggestedTeamSize:
                    state.estimatePrice?.recommendation?.suggestedTeamSize,
                helpTypeId: _selectedHelpType!.id,
                helpTypeLabel: _selectedHelpType!.label,
                specialRequirementId: _selectedSpecialRequirement!.id,
                specialRequirementLabel: specialRequirement ?? 'لا يوجد',
                notes: _enableNotes ? _notesController.text.trim() : null,
              ),
            );
          } else if (state.estimatePriceStatus == BlocStatus.failed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'تعذر حساب تكلفة طلب المناسبة',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final serviceOptions = state.cleaningServices
              .where((service) => service.id != null)
              .map(
                (service) => _MenuOption(
                  id: 'service_${service.id}',
                  label: service.name ?? 'خدمة رقم ${service.id}',
                  serviceId: service.id,
                ),
              )
              .toList(growable: false);

          final isLoadingServices =
              state.cleaningServicesStatus == BlocStatus.loading;
          final servicesError =
              state.cleaningServicesStatus == BlocStatus.failed
              ? state.errorMessage
              : null;

          return Scaffold(
            backgroundColor: const Color(0xFFF2F2F2),
            body: SafeArea(
              child: Column(
                children: [
                  const HomeDetailsAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        20,
                        16,
                        20,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              14,
                              12,
                              14,
                              12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.event_rounded,
                                  color: Color(0xFF11B9C8),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppText.bodyMedium(
                                    'توصيف المناسبة: $occasionTitle',
                                    color: const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClHomeDescriptionTitleCardWidget(
                            step: 1,
                            title: 'عدد الضيوف',
                            subtitle: 'حدد العدد التقريبي للضيوف',
                            child: _GuestsCounter(
                              guestsCount: _guestsCount,
                              onAdd: () => setState(() => _guestsCount += 1),
                              onSubtract: () {
                                if (_guestsCount <= 1) return;
                                setState(() => _guestsCount -= 1);
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClHomeDescriptionTitleCardWidget(
                            step: 2,
                            title: 'ما هي طبيعة المساعدة المطلوبة؟',
                            subtitle: 'اختر نوع المساعدة من القائمة',
                            child: Column(
                              children: [
                                ClSelectableMenuFieldWidget(
                                  key: const Key('occasion_help_type_field'),
                                  value: _selectedHelpType?.label,
                                  hint: isLoadingServices
                                      ? 'جاري تحميل الخدمات...'
                                      : 'اختر طبيعة المساعدة المطلوبة',
                                  onTap: () => _selectHelpType(serviceOptions),
                                ),
                                if (servicesError != null &&
                                    servicesError.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  AppText.bodySmall(
                                    servicesError,
                                    color: Colors.redAccent,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClHomeDescriptionTitleCardWidget(
                            step: 3,
                            title: 'هل لديك أي متطلبات خاصة؟',
                            subtitle: 'اختر المتطلبات الخاصة إن وجدت',
                            child: ClSelectableMenuFieldWidget(
                              key: const Key(
                                'occasion_special_requirements_field',
                              ),
                              value: _selectedSpecialRequirement?.label,
                              hint: 'اختر المتطلبات الخاصة',
                              onTap: _selectSpecialRequirement,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClHomeDescriptionTitleCardWidget(
                            step: 4,
                            title: 'ملاحظات الطلب',
                            subtitle: 'يمكنك إضافة ملاحظات إضافية (اختياري)',
                            child: Column(
                              children: [
                                CheckboxListTile(
                                  value: _enableNotes,
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: AppText.bodySmall(
                                    'إضافة ملاحظات للطلب',
                                    color: const Color(0xFF374151),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  activeColor: const Color(0xFF11B9C8),
                                  onChanged: (value) {
                                    setState(() {
                                      _enableNotes = value ?? false;
                                    });
                                  },
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _notesController,
                                  minLines: 2,
                                  maxLines: 3,
                                  enabled: _enableNotes,
                                  decoration: InputDecoration(
                                    hintText:
                                        'غسل اطباق أو مساعدة في اشياء معينة',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 12,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    contentPadding:
                                        const EdgeInsetsDirectional.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF11B9C8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClMainContinueButtonWidget(
                            key: const Key(
                              'occasion_description_continue_button',
                            ),
                            onPressed: isLoadingServices
                                ? null
                                : () => _onContinue(bloc),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GuestsCounter extends StatelessWidget {
  const _GuestsCounter({
    required this.guestsCount,
    required this.onAdd,
    required this.onSubtract,
  });

  final int guestsCount;
  final VoidCallback onAdd;
  final VoidCallback onSubtract;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _CounterActionButton(
            icon: Icons.remove_rounded,
            onTap: onSubtract,
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5E1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppText.bodyMedium(
                '$guestsCount',
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _CounterActionButton(
            icon: Icons.add_rounded,
            onTap: onAdd,
            color: const Color(0xFF11B9C8),
          ),
        ],
      ),
    );
  }
}

class _CounterActionButton extends StatelessWidget {
  const _CounterActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}
