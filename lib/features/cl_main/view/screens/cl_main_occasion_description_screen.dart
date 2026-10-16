import 'package:dllni_user_app/core/themes/shared_platform_colors.dart';
import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/models/address_list_item.dart';
import '../../data/models/cleaning_suite_config_model.dart';
import '../data/cl_main_route_args.dart';
import '../helpers/cl_event_assignment_helper.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/cl_redesign_components.dart';
import '../helpers/cl_event_collected_fields.dart';
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
  late List<_MenuOption> _helpTypeOptions;
  // The default 'none' option may need to be prepended to event-specific
  // requirements (for example, large gatherings). This list is mutable.

  final ScrollController _detailsScrollController = ScrollController();
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
  bool _didNavigateToSchedule = false;
  bool _exitConfirmed = false;
  int _descriptionStep = 0;

  String get _customServiceValue {
    final typed = _customServiceController.text.trim();
    if (typed.isNotEmpty) return typed;
    return _selectedHelpType?.label ?? '';
  }

  @override
  void initState() {
    super.initState();
    _initializeDefaults(widget.args);
    _selectedAddress = ValueNotifier<AddressListItem?>(null);
  }

  void _initializeDefaults(ClMainOccasionDescriptionArgs? args) {
    // The admin-managed card ID can differ from the booking slug.
    // Use the backend booking value to select occasion defaults.
    final occasionId = args?.option.bookingValue;

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
        break;

      case 'birthday_party':
      case 'birthday':
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
        break;

      case 'condolences':
      case 'funeral':
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
        break;

      default:
        _guestsCount = 10;
        _hoursCount = 3;
        _workersCount = 1;
        _helpTypeOptions = const [
          _MenuOption(id: 'custom', label: 'مساعدة عامة'),
        ];
        break;
    }
  }

  @override
  void didUpdateWidget(covariant ClMainOccasionDescriptionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.args?.option.bookingValue ==
        widget.args?.option.bookingValue) {
      return;
    }
    for (final controller in _dynamicControllers.values) {
      controller.dispose();
    }
    _dynamicControllers.clear();
    _dynamicValues.clear();
    _customServiceController.clear();
    _notesController.clear();
    _selectedHelpType = null;
    _routeArgs = widget.args;
    _bloc = widget.args?.bloc;
    _didReadArgs = widget.args != null;
    _didNavigateToSchedule = false;
    _descriptionStep = 0;
    _selectedAddress.value = null;
    _initializeDefaults(widget.args);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _bloc;
    if (bloc == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F7F9),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }
    final occasionTitle = _routeArgs?.option.title ?? 'المناسبة';

    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<ClMainBloc, ClMainState>(
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: PopScope(
              canPop: _exitConfirmed,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) _confirmExit();
              },
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: const Color(0xFFF6F7F9),
                body: SafeArea(
                  child: Column(
                    children: [
                      HomeDetailsAppBar(
                        title: 'طلب مناسبة',
                        subtitle: 'أكمل تفاصيل مناسبتك خطوة بخطوة',
                        onBack: _confirmExit,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _detailsScrollController,
                          padding: EdgeInsets.fromLTRB(
                            16,
                            18,
                            16,
                            24 + MediaQuery.viewInsetsOf(context).bottom,
                          ),
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
                        primaryEnabled: !_didNavigateToSchedule,
                        secondaryLabel: _descriptionStep > 0 ? 'السابق' : null,
                        onSecondary: _descriptionStep > 0
                            ? () => _goToDescriptionStep(0)
                            : null,
                      ),
                    ],
                  ),
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
          totalSteps: 5,
          title: 'تفاصيل المناسبة',
          subtitle:
              'أخبرنا بحجم المناسبة وطبيعة المساعدة حتى نقدر الوقت والفريق المناسبين.',
        ),
        const SizedBox(height: 14),
        ClRedesignCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_rounded,
                  color: Color(0xFF172554),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نوع المناسبة',
                      style: TextStyle(color: Color(0xFF697386), fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      occasionTitle,
                      style: const TextStyle(
                        color: Color(0xFF182232),
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
          maxValue: maxEventGuestCount,
          onIncrement: () {
            if (_guestsCount >= maxEventGuestCount) return;
            setState(() => _guestsCount += 1);
          },
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
                  color: Color(0xFF182232),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'اختر اقتراحاً أو اكتب وصفاً يناسب احتياج المناسبة.',
                textAlign: TextAlign.start,
                style: TextStyle(color: Color(0xFF697386), fontSize: 12),
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
          totalSteps: 5,
          title: 'المتطلبات ومكان الخدمة',
          subtitle:
              'أكمل التفاصيل المدعومة للطلب. يمكنك إضافة الملاحظات فقط عند الحاجة.',
        ),
        const SizedBox(height: 18),
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
      hintStyle: const TextStyle(color: Color(0xFF697386), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF365487)),
      ),
    );
  }

  Future<void> _confirmExit() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('هل تريد مغادرة طلب المناسبة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('متابعة الطلب'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('مغادرة'),
          ),
        ],
      ),
    );
    if (shouldLeave == true && mounted) {
      setState(() => _exitConfirmed = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  void _goToDescriptionStep(int step) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _descriptionStep = step);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _detailsScrollController.hasClients) {
        _detailsScrollController.jumpTo(0);
      }
    });
  }

  void _onDescriptionPrimaryPressed(ClMainBloc bloc) {
    FocusManager.instance.primaryFocus?.unfocus();
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
      _goToDescriptionStep(1);
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
      if (widget.args == null) _initializeDefaults(args);
      for (final field in args.option.dynamicFields) {
        if (field.type == 'yes_no') {
          _dynamicValues.putIfAbsent(field.key, () => false);
        } else if (field.type != 'single_select' &&
            field.type != 'multi_select') {
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
    _detailsScrollController.dispose();
    _customServiceController.dispose();
    _notesController.dispose();
    for (final controller in _dynamicControllers.values) {
      controller.dispose();
    }
    _selectedAddress.dispose();
    super.dispose();
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

    if (_didNavigateToSchedule) return;
    _didNavigateToSchedule = true;
    final scheduleArgs = ClMainOccasionScheduleArgs(
      option: args.option,
      bloc: bloc,
      estimate: null,
      guestsCount: _guestsCount,
      eventType: _eventTypeFromOption(args.option),
      venueType: resolveEventVenueType(_eventDynamicAnswers),
      customService: customService,
      hours: _hoursCount.toDouble(),
      numberOfWorkers: _workersCount,
      suggestedTeamSize: null,
      helpTypeId: _selectedHelpType?.id ?? 'custom',
      helpTypeLabel: customService,
      specialRequirementId: 'none',
      specialRequirementLabel: 'لا يوجد',
      defaultAddress: selectedAddress,
      notes: _enableNotes ? _notesController.text.trim() : null,
      eventTypeId: args.option.eventTypeId,
      eventDynamicAnswers: _eventDynamicAnswers,
    );
    if (!(args.navigateToScheduleOnEstimate)) {
      _didNavigateToSchedule = false;
      return;
    }
    Future<void>.sync(() async {
      await context.pushRoute(
        '/clmainoccasionschedule',
        arguments: scheduleArgs,
      );
    }).whenComplete(() {
      if (mounted) setState(() => _didNavigateToSchedule = false);
    });
  }

  CleaningDynamicFieldConfigModel? _firstInvalidDynamicField() {
    for (final field in _routeArgs?.option.dynamicFields ?? const []) {
      if (isPreviouslyCollectedGuestCount(field)) continue;
      if (!field.required) continue;
      final value = _eventDynamicAnswers[field.key];
      if (value == null || value == '' || (value is List && value.isEmpty)) {
        return field;
      }
    }
    return null;
  }

  bool _isDuplicateOptionalSpecialNotes(CleaningDynamicFieldConfigModel field) {
    final key = field.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return !field.required &&
        (key == 'specialnotes' ||
            key == 'specialrequirements' ||
            key == 'specialrequestnotes');
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
    return mergeCollectedGuestsIntoDynamicAnswers(
      fields: _routeArgs?.option.dynamicFields ?? const [],
      answers: result,
      guestCount: _guestsCount,
    );
  }

  Widget _buildDynamicFieldsCard() {
    final fields = (_routeArgs?.option.dynamicFields ?? const [])
        .where(
          (field) =>
              !isPreviouslyCollectedGuestCount(field) &&
              !_isDuplicateOptionalSpecialNotes(field),
        )
        .toList(growable: false);
    if (fields.isEmpty) return const SizedBox.shrink();
    return ClRedesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'تفاصيل إضافية للمناسبة',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xFF182232),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'أضف التفاصيل التي تساعد الفريق على الاستعداد لمناسبتك.',
            textAlign: TextAlign.start,
            style: TextStyle(color: Color(0xFF697386), fontSize: 12),
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

  String _eventOptionLabel(
    CleaningDynamicFieldConfigModel field,
    String value,
  ) {
    for (final option in field.options) {
      if (option is! Map) continue;
      final optionValue = (option['value'] ?? option['id'])?.toString().trim();
      if (optionValue != value) continue;
      final label = (option['label'] ?? option['name'])?.toString().trim();
      if (label != null && label.isNotEmpty) return label;
    }
    if (field.key.toLowerCase().replaceAll('_', '') == 'venuetype') {
      return switch (value.toLowerCase()) {
        'home' || 'apartment' => 'المنزل',
        'hall' => 'صالة مناسبات',
        'garden' => 'حديقة',
        'office' => 'مكتب',
        _ => value,
      };
    }
    return value;
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
        .map(
          (value) => value is Map
              ? (value['value'] ?? value['id'] ?? '').toString().trim()
              : value.toString().trim(),
        )
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
              (value) => DropdownMenuItem<String>(
                value: value,
                child: Text(_eventOptionLabel(field, value)),
              ),
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
                      label: Text(_eventOptionLabel(field, value)),
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
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onFieldSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
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
                          ? SharedPlatformColors.cleaningInk
                          : SharedPlatformColors.muted,
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
