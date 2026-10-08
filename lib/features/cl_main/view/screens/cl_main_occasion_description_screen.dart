import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/models/address_list_item.dart';
import '../../data/models/cleaning_suite_config_model.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../helpers/cl_event_assignment_helper.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/cl_redesign_components.dart';
import '../widgets/cl_selectable_menu_field_widget.dart';
import '../widgets/cl_service_address_section_widget.dart';
import '../widgets/home_details_app_bar.dart';

@AutoRoutePage()
class ClMainOccasionDescriptionScreen extends StatefulWidget {
  final ClMainOccasionDescriptionArgs? args;

  const ClMainOccasionDescriptionScreen({this.args, super.key});

  @override
  State<ClMainOccasionDescriptionScreen> createState() =>
      _ClMainOccasionDescriptionScreenState();
}

class _ClMainOccasionDescriptionScreenState
    extends State<ClMainOccasionDescriptionScreen> {
  late int _guestsCount;
  late int _hoursCount;
  late int _workersCount;
  late final List<_MenuOption> _helpTypeOptions;
  late final List<_MenuOption> _specialRequirementOptions;

  final TextEditingController _customServiceController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final Map<String, TextEditingController> _dynamicControllers =
      <String, TextEditingController>{};
  final Map<String, dynamic> _dynamicValues = <String, dynamic>{};
  late final ValueNotifier<AddressListItem?> _selectedAddress;

  bool _enableNotes = false;
  ClMainOccasionDescriptionArgs? _routeArgs;
  ClMainBloc? _bloc;
  bool _didReadArgs = false;
  _MenuOption? _selectedHelpType;
  _MenuOption? _selectedSpecialRequirement;
  bool _didNavigateToSchedule = false;
  int _descriptionStep = 0;

  String get _customServiceValue {
    final typed = _customServiceController.text.trim();
    if (typed.isNotEmpty) return typed;
    return _selectedHelpType?.label ?? '';
  }

  int get _minimumWorkersForSelectedHours =>
      resolveMinimumEventWorkersForHours(_hoursCount.toDouble());

  int get _resolvedWorkersCount => resolveEventWorkerCountForHours(
    hours: _hoursCount.toDouble(),
    requestedWorkers: _workersCount,
  );

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
    _selectedAddress = ValueNotifier<AddressListItem?>(null);
  }

  void _initializeDefaults() {
    final occasionId = widget.args?.option.id;

    switch (occasionId) {
      case 'family_dinner':
        _guestsCount = 10;
        _hoursCount = 3;
        _workersCount = 1;
        _helpTypeOptions = [
          const _MenuOption(id: 'table_setup', label: 'تجهيز طاولة العشاء'),
          const _MenuOption(id: 'manual_help', label: 'مساعدة يدوية في المطبخ'),
          const _MenuOption(id: 'serving', label: 'تقديم الطعام للضيوف'),
          const _MenuOption(id: 'cleanup', label: 'تنظيف المائدة بعد العشاء'),
        ];
        _specialRequirementOptions = [
          const _MenuOption(id: 'none', label: 'لا يوجد'),
          const _MenuOption(id: 'quick_setup', label: 'تجهيز سريع قبل الوصول'),
          const _MenuOption(
            id: 'kids_safety',
            label: 'انتباه خاص لسلامة الأطفال',
          ),
          const _MenuOption(id: 'extra_seating', label: 'ترتيب مقاعد إضافية'),
        ];
        break;

      case 'birthday_party':
        _guestsCount = 20;
        _hoursCount = 4;
        _workersCount = 2;
        _helpTypeOptions = [
          const _MenuOption(
            id: 'serving_support',
            label: 'دعم توزيع المشروبات والحلويات',
          ),
          const _MenuOption(
            id: 'decoration_help',
            label: 'المساعدة في ترتيب الزينة',
          ),
          const _MenuOption(id: 'gift_management', label: 'تنظيم ركن الهدايا'),
          const _MenuOption(
            id: 'post_party_cleanup',
            label: 'تنظيف المكان بعد الحفلة',
          ),
        ];
        _specialRequirementOptions = [
          const _MenuOption(id: 'none', label: 'لا يوجد'),
          const _MenuOption(id: 'cake_ceremony', label: 'تنسيق فقرة الكيك'),
          const _MenuOption(
            id: 'music_coordination',
            label: 'متابعة وتيرة الموسيقى',
          ),
          const _MenuOption(
            id: 'extra_attention',
            label: 'عناية إضافية لمنطقة البوفيه',
          ),
        ];
        break;

      case 'large_gathering':
        _guestsCount = 40;
        _hoursCount = 6;
        _workersCount = 3;
        _helpTypeOptions = [
          const _MenuOption(
            id: 'hospitality_setup',
            label: 'تجهيز كامل لمنطقة الضيافة',
          ),
          const _MenuOption(
            id: 'reception_support',
            label: 'دعم استقبال الضيوف',
          ),
          const _MenuOption(
            id: 'food_refill',
            label: 'متابعة إعادة تعبئة الطعام',
          ),
          const _MenuOption(
            id: 'full_cleanup',
            label: 'تنظيف شامل وتنسيق بعد المناسبة',
          ),
        ];
        _specialRequirementOptions = [
          const _MenuOption(
            id: 'separate_teams',
            label: 'توزيع فريق العمل على أقسام',
          ),
          const _MenuOption(
            id: 'valet_support',
            label: 'المساعدة في تنظيم المواقف',
          ),
          const _MenuOption(
            id: 'security_awareness',
            label: 'انتباه وتنسيق حركة الضيوف',
          ),
          const _MenuOption(
            id: 'dynamic_service',
            label: 'خدمة مرنة حسب احتياج القاعة',
          ),
        ];
        break;

      case 'condolences':
        _guestsCount = 30;
        _hoursCount = 5;
        _workersCount = 2;
        _helpTypeOptions = [
          const _MenuOption(
            id: 'hospitality_setup',
            label: 'تجهيز ركن القهوة والضيافة',
          ),
          const _MenuOption(
            id: 'serving_support',
            label: 'تقديم مستمر للضيافة',
          ),
          const _MenuOption(
            id: 'silent_service',
            label: 'خدمة هادئة غير ملفتة',
          ),
          const _MenuOption(
            id: 'cleanup_support',
            label: 'تنظيف وتغيير أكواب الضيافة',
          ),
        ];
        _specialRequirementOptions = [
          const _MenuOption(id: 'none', label: 'لا يوجد'),
          const _MenuOption(
            id: 'continuous_cleaning',
            label: 'تنظيف مستمر أثناء العزاء',
          ),
          const _MenuOption(
            id: 'high_traffic',
            label: 'عناية إضافية بالمداخل والممرات',
          ),
          const _MenuOption(
            id: 'restrooms',
            label: 'متابعة نظافة دورات المياه',
          ),
        ];
        break;

      default:
        _guestsCount = 10;
        _hoursCount = 3;
        _workersCount = 1;
        _helpTypeOptions = const [
          _MenuOption(id: 'custom', label: 'مساعدة عامة'),
        ];
        _specialRequirementOptions = const [
          _MenuOption(id: 'none', label: 'لا يوجد'),
        ];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _bloc;
    if (bloc == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F8FA),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    final occasionTitle = _routeArgs?.option.title ?? 'المناسبة';

    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<ClMainBloc, ClMainState>(
        listenWhen: (previous, current) =>
            previous.estimatePriceStatus != current.estimatePriceStatus,
        listener: (context, state) async {
          if (state.estimatePriceStatus == BlocStatus.loading) return;
          if ((_routeArgs?.navigateToScheduleOnEstimate ?? true) &&
              !_didNavigateToSchedule &&
              state.estimatePriceStatus == BlocStatus.success &&
              state.estimatePrice != null &&
              _routeArgs != null &&
              _selectedSpecialRequirement != null) {
            _didNavigateToSchedule = true;
            final eventType = _eventTypeFromOption(_routeArgs!.option);
            final customService = _customServiceValue;
            final specialRequirement = _selectedSpecialRequirement!.id == 'none'
                ? null
                : _selectedSpecialRequirement!.label;
            final resolvedWorkersCount = _resolvedWorkersCount;
            final suggestedTeamSize =
                state.estimatePrice?.suggestedTeamSize ?? resolvedWorkersCount;
            final scheduleArgs = ClMainOccasionScheduleArgs(
              option: _routeArgs!.option,
              bloc: bloc,
              estimate: state.estimatePrice!,
              guestsCount: _guestsCount,
              eventType: eventType,
              venueType: 'apartment',
              customService: customService,
              hours: _hoursCount.toDouble(),
              numberOfWorkers: resolvedWorkersCount,
              suggestedTeamSize: suggestedTeamSize,
              helpTypeId: _selectedHelpType?.id ?? 'custom',
              helpTypeLabel: customService,
              specialRequirementId: _selectedSpecialRequirement!.id,
              specialRequirementLabel: specialRequirement ?? 'لا يوجد',
              defaultAddress: _selectedAddress.value,
              notes: _enableNotes ? _notesController.text.trim() : null,
              eventTypeId: _routeArgs!.option.eventTypeId,
              eventDynamicAnswers: _eventDynamicAnswers,
            );
            await context.pushRoute(
              '/clmainoccasionschedule',
              arguments: scheduleArgs,
            );
            _didNavigateToSchedule = false;
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
          final isEstimating = state.estimatePriceStatus == BlocStatus.loading;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F8FA),
              body: SafeArea(
                child: Column(
                  children: [
                    const HomeDetailsAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _descriptionStep == 0
                              ? _buildOccasionBasicsStep(occasionTitle)
                              : _buildOccasionRequirementsStep(),
                        ),
                      ),
                    ),
                    ClRedesignStickyActions(
                      primaryLabel: _descriptionStep == 0
                          ? 'التالي'
                          : 'متابعة إلى الموعد',
                      onPrimary: () => _onDescriptionPrimaryPressed(bloc),
                      primaryEnabled: !isEstimating,
                      secondaryLabel: _descriptionStep > 0 ? 'السابق' : null,
                      onSecondary: _descriptionStep > 0
                          ? () => setState(() => _descriptionStep = 0)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOccasionBasicsStep(String occasionTitle) {
    return Column(
      key: const ValueKey('occasion_basics_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ClRedesignStepHeader(
          currentStep: 1,
          totalSteps: 2,
          title: 'تفاصيل المناسبة',
          subtitle:
              'أخبرنا بحجم المناسبة وطبيعة المساعدة حتى نقدر الوقت والفريق المناسبين.',
        ),
        const SizedBox(height: 18),
        ClRedesignCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_rounded,
                  color: Color(0xFF0F8E98),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نوع المناسبة',
                      style: TextStyle(color: Color(0xFF667085), fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      occasionTitle,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ClRedesignCounter(
          label: 'عدد الضيوف',
          icon: Icons.groups_2_outlined,
          value: _guestsCount,
          onIncrement: () => setState(() => _guestsCount += 1),
          onDecrement: () {
            if (_guestsCount <= 1) return;
            setState(() => _guestsCount -= 1);
          },
        ),
        const SizedBox(height: 12),
        ClRedesignCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'طبيعة المساعدة المطلوبة',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Color(0xFF172033),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'اختر اقتراحاً أو اكتب وصفاً يناسب احتياج المناسبة.',
                textAlign: TextAlign.start,
                style: TextStyle(color: Color(0xFF667085), fontSize: 12),
              ),
              const SizedBox(height: 12),
              ClSelectableMenuFieldWidget(
                key: const Key('occasion_help_type_field'),
                value: _selectedHelpType?.label,
                hint: 'اختر اقتراحاً سريعاً',
                onTap: _selectHelpType,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _customServiceController,
                maxLength: 255,
                minLines: 2,
                maxLines: 3,
                textAlign: TextAlign.start,
                decoration: _redesignInputDecoration(
                  hintText: 'اكتب وصف المساعدة المطلوبة',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ClRedesignCounter(
          label: 'مدة الخدمة بالساعات',
          icon: Icons.schedule_outlined,
          value: _hoursCount,
          onIncrement: () {
            if (_hoursCount >= 24) return;
            _setHoursCount(_hoursCount + 1);
          },
          onDecrement: () {
            if (_hoursCount <= 1) return;
            _setHoursCount(_hoursCount - 1);
          },
        ),
        const SizedBox(height: 12),
        ClRedesignCounter(
          label: 'عدد العمال المطلوبين',
          icon: Icons.engineering_outlined,
          value: _workersCount,
          onIncrement: () => setState(() => _workersCount += 1),
          onDecrement: () {
            if (_workersCount <= _minimumWorkersForSelectedHours) return;
            setState(() => _workersCount -= 1);
          },
        ),
        const SizedBox(height: 8),
        Text(
          'الحد الأدنى المقترح لهذه المدة: $_minimumWorkersForSelectedHours عامل',
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOccasionRequirementsStep() {
    return Column(
      key: const ValueKey('occasion_requirements_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ClRedesignStepHeader(
          currentStep: 2,
          totalSteps: 2,
          title: 'المتطلبات ومكان الخدمة',
          subtitle:
              'أكمل التفاصيل المدعومة للطلب. يمكنك إضافة الملاحظات فقط عند الحاجة.',
        ),
        const SizedBox(height: 18),
        ClRedesignCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'متطلبات خاصة',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Color(0xFF172033),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ClSelectableMenuFieldWidget(
                key: const Key('occasion_special_requirements_field'),
                value: _selectedSpecialRequirement?.label,
                hint: 'اختر المتطلبات الخاصة',
                onTap: _selectSpecialRequirement,
              ),
            ],
          ),
        ),
        if (_routeArgs?.option.dynamicFields.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _buildDynamicFieldsCard(),
        ],
        const SizedBox(height: 12),
        CleaningAddressSelectWidget(
          selectedAddress: _selectedAddress,
          onChangeTap: _selectAddress,
        ),
        const SizedBox(height: 12),
        ClRedesignCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _enableNotes,
                title: const Text(
                  'إضافة ملاحظات للطلب',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'اختياري — استخدمها فقط للتفاصيل التي يحتاجها العامل.',
                  textAlign: TextAlign.start,
                ),
                onChanged: (value) => setState(() => _enableNotes = value),
              ),
              if (_enableNotes) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 4,
                  textAlign: TextAlign.start,
                  decoration: _redesignInputDecoration(
                    hintText: 'أضف ملاحظة مختصرة للعامل',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _redesignInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF12B8C4)),
      ),
    );
  }

  void _onDescriptionPrimaryPressed(ClMainBloc bloc) {
    if (_descriptionStep == 0) {
      final customService = _customServiceValue;
      if (customService.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال طبيعة المساعدة المطلوبة')),
        );
        return;
      }
      if (customService.length > 255) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('وصف المساعدة يجب ألا يتجاوز 255 حرفاً'),
          ),
        );
        return;
      }
      setState(() => _descriptionStep = 1);
      return;
    }
    _onContinue(bloc);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    _didReadArgs = true;

    final args = widget.args ?? ModalRoute.of(context)?.settings.arguments;
    if (args is ClMainOccasionDescriptionArgs) {
      _routeArgs = args;
      for (final field in args.option.dynamicFields) {
        if (field.type == 'boolean' || field.type == 'bool') {
          _dynamicValues.putIfAbsent(field.key, () => false);
        } else if (field.type != 'select' &&
            field.type != 'choice' &&
            field.type != 'dropdown') {
          _dynamicControllers.putIfAbsent(field.key, TextEditingController.new);
        }
      }
      _bloc = args.bloc;
      _bloc?.add(
        SetGenderPreferenceEvent(preference: CleaningGenderPreference.male),
      );
      _bloc?.add(ClearPreferredWorkersEvent());
    }
  }

  @override
  void dispose() {
    _customServiceController.dispose();
    _notesController.dispose();
    for (final controller in _dynamicControllers.values) {
      controller.dispose();
    }
    _selectedAddress.dispose();
    super.dispose();
  }

  void _setHoursCount(int value) {
    final safeHours = value.clamp(1, 24).toInt();
    setState(() {
      _hoursCount = safeHours;
      final minimumWorkers = _minimumWorkersForSelectedHours;
      if (_workersCount < minimumWorkers) {
        _workersCount = minimumWorkers;
      }
    });
  }

  String _eventTypeFromOption(ClMainOccasionOption option) {
    if (option.bookingValue.trim().isNotEmpty) return option.bookingValue;
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

  void _onContinue(ClMainBloc bloc) {
    final args = _routeArgs;
    if (args == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحميل بيانات المناسبة')),
      );
      return;
    }

    final customService = _customServiceValue;
    if (customService.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال طبيعة المساعدة المطلوبة')),
      );
      return;
    }
    if (customService.length > 255) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وصف المساعدة يجب ألا يتجاوز 255 حرفاً')),
      );
      return;
    }
    if (_selectedSpecialRequirement == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المتطلبات الخاصة')),
      );
      return;
    }
    final invalidDynamicField = _firstInvalidDynamicField();
    if (invalidDynamicField != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى تعبئة حقل ${invalidDynamicField.label}.')),
      );
      return;
    }
    final selectedAddress = _selectedAddress.value;
    final addressId = int.tryParse(selectedAddress?.id ?? '') ?? 0;
    if (selectedAddress == null || addressId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار عنوان الخدمة أولاً')),
      );
      return;
    }
    if (!selectedAddress.hasCompleteServiceLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار عنوان يحتوي على موقع محدد على الخريطة وعنوان واضح',
          ),
        ),
      );
      return;
    }

    final eventType = _eventTypeFromOption(args.option);
    final specialRequirement = _selectedSpecialRequirement!.id == 'none'
        ? null
        : _selectedSpecialRequirement!.label;

    bloc.add(ClearPreferredWorkersEvent());
    bloc.add(
      EstimateCleaningPriceEvent(
        params: EstimateCleaningPriceParams.eventAssistance(
          eventType: eventType,
          eventTypeId: args.option.eventTypeId,
          eventDynamicAnswers: _eventDynamicAnswers,
          guestCount: _guestsCount,
          venueType: 'apartment',
          customService: customService,
          hours: _hoursCount.toDouble(),
          addressId: addressId,
          addressLatitude: selectedAddress.latitude,
          addressLongitude: selectedAddress.longitude,
          numberOfWorkers: _resolvedWorkersCount,
          preferredWorkerIds: const <int>[],
          assignmentMode: CleaningAssignmentMode.openCount,
          specialRequirement: specialRequirement,
          notes: _enableNotes ? _notesController.text.trim() : null,
        ),
      ),
    );
  }

  CleaningDynamicFieldConfigModel? _firstInvalidDynamicField() {
    for (final field in _routeArgs?.option.dynamicFields ?? const []) {
      if (!field.required) continue;
      final value = _eventDynamicAnswers[field.key];
      if (value == null || value == '' || (value is List && value.isEmpty)) {
        return field;
      }
    }
    return null;
  }

  Map<String, dynamic> get _eventDynamicAnswers {
    final result = <String, dynamic>{..._dynamicValues};
    for (final entry in _dynamicControllers.entries) {
      final text = entry.value.text.trim();
      if (text.isEmpty) continue;
      final field = (_routeArgs?.option.dynamicFields ?? const [])
          .where((item) => item.key == entry.key)
          .firstOrNull;
      result[entry.key] = field?.type == 'number'
          ? (num.tryParse(text) ?? text)
          : text;
    }
    result.removeWhere(
      (_, value) =>
          value == null || value == '' || (value is List && value.isEmpty),
    );
    return result;
  }

  Widget _buildDynamicFieldsCard() {
    final fields = _routeArgs?.option.dynamicFields ?? const [];
    if (fields.isEmpty) return const SizedBox.shrink();
    return ClRedesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'تفاصيل إضافية للمناسبة',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xFF172033),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'هذه الحقول تأتي من إعدادات نوع المناسبة الحالية.',
            textAlign: TextAlign.start,
            style: TextStyle(color: Color(0xFF667085), fontSize: 12),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < fields.length; index++) ...[
            _buildDynamicField(fields[index]),
            if (index < fields.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildDynamicField(CleaningDynamicFieldConfigModel field) {
    final label = field.required ? '${field.label} *' : field.label;
    if (field.type == 'yes_no') {
      return Semantics(
        label: field.label,
        toggled: _dynamicValues[field.key] == true,
        child: SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          subtitle: const Text('اختر نعم عند انطباق هذا الخيار.'),
          value: _dynamicValues[field.key] == true,
          onChanged: (value) => setState(() {
            _dynamicValues[field.key] = value;
          }),
        ),
      );
    }

    final options = field.options
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (field.type == 'single_select') {
      return DropdownButtonFormField<String>(
        initialValue: _dynamicValues[field.key] as String?,
        decoration: InputDecoration(
          labelText: label,
          helperText: field.required ? 'هذا الحقل مطلوب.' : 'اختياري',
          border: const OutlineInputBorder(),
        ),
        items: options
            .map(
              (value) =>
                  DropdownMenuItem<String>(value: value, child: Text(value)),
            )
            .toList(growable: false),
        onChanged: (value) => setState(() {
          _dynamicValues[field.key] = value;
        }),
      );
    }

    if (field.type == 'multi_select') {
      final selected =
          (_dynamicValues[field.key] as List?)
              ?.map((value) => value.toString())
              .toSet() ??
          <String>{};
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (value) => ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: FilterChip(
                      label: Text(value),
                      selected: selected.contains(value),
                      onSelected: (enabled) => setState(() {
                        final next = <String>{...selected};
                        enabled ? next.add(value) : next.remove(value);
                        _dynamicValues[field.key] = next.toList();
                      }),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          Text(
            field.required ? 'اختر خياراً واحداً على الأقل.' : 'اختياري',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    final controller = _dynamicControllers.putIfAbsent(
      field.key,
      TextEditingController.new,
    );
    return TextFormField(
      controller: controller,
      keyboardType: field.type == 'number'
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      minLines: field.type == 'textarea' ? 2 : 1,
      maxLines: field.type == 'textarea' ? 4 : 1,
      decoration: InputDecoration(
        labelText: label,
        helperText: field.required ? 'هذا الحقل مطلوب.' : 'اختياري',
        border: const OutlineInputBorder(),
      ),
    );
  }

  Future<void> _selectAddress() async {
    final selectedAddress = await context.pushRoute(
      '/myaddresses',
      arguments: true,
    );
    if (!mounted) return;
    if (selectedAddress is AddressListItem) {
      setState(() {
        _selectedAddress.value = selectedAddress;
      });
    }
  }

  Future<void> _selectHelpType() async {
    final value = await _showOptionsBottomSheet(
      title: 'ما هي طبيعة المساعدة المطلوبة؟',
      options: _helpTypeOptions,
      currentValue: _selectedHelpType,
    );
    if (!mounted || value == null) return;
    setState(() {
      _selectedHelpType = value;
      if (value.id != 'other') {
        _customServiceController.text = value.label;
      }
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
                  color: SharedPlatformColors.cleaning,
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
                    trailing: Icon(
                      currentValue?.id == option.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: currentValue?.id == option.id
                          ? const Color(0xFF11B9C8)
                          : const Color(0xFF98A2B3),
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
}

class _MenuOption {
  final String id;
  final String label;

  const _MenuOption({required this.id, required this.label});
}
