import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import '../../domain/models/cleaning_progressive_room_state.dart';
import '../../domain/models/cleaning_room_size_breakdown.dart';
import '../../domain/models/cleaning_type.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/cl_redesign_components.dart';
import '../widgets/cl_booking_pencil_header.dart';
import '../../../../core/widgets/design_system/design_system.dart';
import '../widgets/v6_room_size_guide.dart';
import 'cleaning_booking_v2_screen.dart';
import '../../domain/models/cleaning_booking_draft.dart';

@AutoRoutePage()
class ClMainHomeDescriptionScreen extends StatefulWidget {
  const ClMainHomeDescriptionScreen({super.key});

  @override
  State<ClMainHomeDescriptionScreen> createState() =>
      _ClMainHomeDescriptionScreenState();
}

class _ClMainHomeDescriptionScreenState
    extends State<ClMainHomeDescriptionScreen> {
  static const _pencilTitles = [
    'شو بدك ننظّف؟',
    'ما حجم كل غرفة؟',
    'تنظيف يومي أم أعمق؟',
  ];
  static const _pencilHints = [
    'حدّد عدد المساحات المطلوبة.',
    'اختَر الأقرب لمساحتك. علامة المساعدة توضّح الأمثلة.',
    'يمكنك اختيار نوع مختلف لكل غرفة.',
  ];
  static const _primaryRoomTypes = allCleaningRoomTypes;

  final ScrollController _bookingScrollController = ScrollController();
  CleaningProgressiveRoomState _roomState =
      const CleaningProgressiveRoomState();
  int _currentStep = 0;
  final Set<String> _reviewedRoomKeys = <String>{};

  String _propertyType = 'apartment';
  AddressListItem? _defaultAddress;
  ClMainBloc? _bloc;
  bool _didReadArgs = false;
  bool _exitDialogOpen = false;

  CleaningRoomSizeBreakdown get _roomSizeBreakdown => _roomState.toBreakdown();

  @override
  Widget build(BuildContext context) {
    final bloc = _bloc ?? getIt<ClMainBloc>();
    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<ClMainBloc, ClMainState>(
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) _confirmExit();
              },
              child: Scaffold(
                backgroundColor: AlnadhaTokens.background,
                body: SafeArea(
                  child: Column(
                    children: [
                      ClBookingTopBar(onExit: _confirmExit),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          20,
                          8,
                          20,
                          6,
                        ),
                        child: ClBookingPencilHeader(
                          step: _currentStep,
                          title: _pencilTitles[_currentStep],
                          subtitle: _pencilHints[_currentStep],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _bookingScrollController,
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _buildStep(state),
                          ),
                        ),
                      ),
                      ClRedesignStickyActions(
                        primaryLabel: _currentStep == 2 ? 'متابعة' : 'متابعة',
                        onPrimary: () => _onPrimaryPressed(bloc, state),
                        primaryEnabled: _canContinueCurrentStep,
                        secondaryLabel: _currentStep > 0 ? 'السابق' : null,
                        onSecondary: _currentStep > 0
                            ? () => _goToStep(_currentStep - 1)
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

  Widget _buildStep(ClMainState state) {
    return switch (_currentStep) {
      0 => _buildRoomCountsStep(),
      1 => _buildRoomSizesStep(),
      _ => _buildCleaningTypeStep(),
    };
  }

  Widget _buildRoomCountsStep() {
    final visibleTypes = _primaryRoomTypes;
    return Column(
      key: const ValueKey('room_counts_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Text(
          'الغرف الأساسية: ${_roomState.totalBaseRooms} من ${CleaningProgressiveRoomState.maxBaseRooms}',
          textAlign: TextAlign.start,
          style: const TextStyle(color: Color(0xFF697386), fontSize: 12),
        ),
        const SizedBox(height: 16),
        for (final type in visibleTypes) ...[
          ClRedesignCounter(
            key: Key('room_count_${type.apiKey}'),
            label: _roomTypeLabel(type),
            icon: _roomTypeIcon(type),
            value: _roomState.countFor(type),
            maxValue: _roomState.maxCountFor(type),
            onIncrement: () => _changeRoomCount(type, 1),
            onDecrement: () => _changeRoomCount(type, -1),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildRoomSizesStep() {
    return Column(
      key: const ValueKey('room_sizes_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        V6RoomSizeIntro(
          onHelp: () => V6RoomSizeHelpSheet.show(
            context,
            _roomState.units.first.roomType,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'راجعت أحجام ${_reviewedRoomKeys.length} من ${_roomState.units.length} مساحة',
          style: const TextStyle(fontSize: 12, color: Color(0xFF697386)),
        ),
        const SizedBox(height: 12),
        for (final unit in _roomState.units) ...[
          ClRedesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_singleRoomLabel(unit.roomType)} ${unit.index}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF172554),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          V6RoomSizeHelpSheet.show(context, unit.roomType),
                      icon: const Icon(Icons.help_outline, size: 18),
                      label: const Text('لست متأكداً؟'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClRedesignSegmentedChoice<CleaningRoomSize>(
                  values: CleaningRoomSize.values,
                  selected: unit.size,
                  labelFor: _roomSizeLabel,
                  onChanged: (size) {
                    setState(() {
                      _roomState = _roomState.setUnitSize(
                        unit.roomType,
                        unit.index,
                        size,
                      );
                      _reviewedRoomKeys.add(unit.key);
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  _reviewedRoomKeys.contains(unit.key)
                      ? 'اختيارك: ${_roomSizeLabel(unit.size)}'
                      : 'الاختيار المبدئي: ${_roomSizeLabel(unit.size)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  RoomSizeGuidance.forType(unit.roomType).example(unit.size),
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF697386),
                  ),
                ),
                if (_roomState.countFor(unit.roomType) > 1 &&
                    unit.index == 1) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _roomState = _roomState.setAllUnitSizes(
                            unit.roomType,
                            unit.size,
                          );
                          for (final matching in _roomState.units) {
                            if (matching.roomType == unit.roomType) {
                              _reviewedRoomKeys.add(matching.key);
                            }
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم تطبيق ${_roomSizeLabel(unit.size)} على كل ${_roomTypeLabel(unit.roomType)}. يمكنك تعديل كل غرفة لاحقاً.',
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_all_outlined, size: 18),
                      label: Text(
                        'تطبيق الحجم على ${_roomState.countFor(unit.roomType)} غرف مشابهة',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  void _showRoomCleaningHelp(CleaningRoomType type) {
    final descriptions = switch (type) {
      CleaningRoomType.bedroom => (
        'ترتيب الغرفة ومسح الأسطح الظاهرة وتنظيف الأرضية.',
        'تنظيف أعمق للزوايا والتفاصيل والأوساخ المتراكمة.',
      ),
      CleaningRoomType.bathroom => (
        'تنظيف المغسلة والمرحاض والأرضية والأسطح المعتادة.',
        'تنظيف مكثف للبلاط والفواصل والتراكمات ضمن نطاق الخدمة.',
      ),
      CleaningRoomType.kitchen => (
        'تنظيف الأسطح الظاهرة والحوض والأرضية.',
        'معالجة أعمق للدهون والزوايا والأسطح ضمن نطاق الخدمة.',
      ),
      CleaningRoomType.livingRoom => (
        'ترتيب الجلسة ومسح الأسطح وتنظيف الأرضية.',
        'تنظيف مكثف للتفاصيل والزوايا والأوساخ المتراكمة.',
      ),
      CleaningRoomType.corridor => (
        'كنس ومسح الممر والأسطح الظاهرة.',
        'عناية أعمق بالحواف والزوايا والأوساخ المتراكمة.',
      ),
      CleaningRoomType.balcony => (
        'كنس ومسح أرضية الشرفة والأسطح المكشوفة.',
        'تنظيف أعمق للأرضية والزوايا والتراكمات المتاحة.',
      ),
      CleaningRoomType.shed => (
        'ترتيب المساحة وتنظيف الأرضية والأسطح القابلة للوصول.',
        'عناية أعمق بالزوايا والغبار المتراكم ضمن نطاق الخدمة.',
      ),
    };
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ما معنى حوسة وتعزيل في ' + _singleRoomLabel(type) + '؟',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'حوسة — تنظيف اعتيادي',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(descriptions.$1),
              const SizedBox(height: 12),
              const Text(
                'تعزيل — تنظيف عميق',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(descriptions.$2),
              const SizedBox(height: 12),
              const Text(
                'غسيل الكنب والسجاد والأجهزة من الداخل خدمات منفصلة عند توفرها.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleaningTypeStep() {
    return Column(
      key: const ValueKey('cleaning_type_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        const ClRedesignCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cleaning_services_outlined,
                    color: Color(0xFF0B7480),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'حوسة — تنظيف وترتيب يومي',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172554),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7),
              Text(
                'مناسبة للغرفة المرتبة نسبياً: ترتيب المكان، إزالة الغبار الظاهر، كنس ومسح الأرضيات وتنظيف الأسطح التي تُستخدم يومياً.',
                style: TextStyle(
                  height: 1.6,
                  fontSize: 13,
                  color: Color(0xFF334155),
                ),
              ),
              Divider(height: 24, color: Color(0xFFE5EAF2)),
              Row(
                children: [
                  Icon(Icons.auto_awesome_outlined, color: Color(0xFF8655A6)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تعزيل — تنظيف أعمق وأكثر تفصيلاً',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172554),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7),
              Text(
                'يشمل أعمال الحوسة، إضافة إلى الاهتمام بالزوايا والحواف والأماكن صعبة الوصول، والأوساخ والدهون أو الترسبات المتراكمة بحسب نوع الغرفة. يحتاج عادةً وقتاً أطول.',
                style: TextStyle(
                  height: 1.6,
                  fontSize: 13,
                  color: Color(0xFF334155),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'غسيل الكنب أو السجاد والتنظيفات التي تحتاج أدوات خاصة تُحدَّد ضمن الخدمات المتخصصة عند توفرها، وليست مشمولة تلقائياً.',
                style: TextStyle(
                  height: 1.5,
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(
                  () => _roomState = _roomState.setAllCleaningTypes(
                    CleaningType.regularCleaning,
                  ),
                ),
                child: const Text('حوسة للكل'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(
                  () => _roomState = _roomState.setAllCleaningTypes(
                    CleaningType.deepCleaning,
                  ),
                ),
                child: const Text('تعزيل للكل'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final unit in _roomState.units) ...[
          ClRedesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _singleRoomLabel(unit.roomType) +
                            ' ' +
                            unit.index.toString() +
                            ' — ' +
                            _roomSizeLabel(unit.size),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    IconButton(
                      key: Key('room_help_' + unit.key.replaceAll('.', '_')),
                      tooltip: 'ما معنى حوسة وتعزيل لهذه الغرفة؟',
                      onPressed: () => _showRoomCleaningHelp(unit.roomType),
                      icon: const Icon(
                        Icons.help_outline,
                        color: Color(0xFF0B7480),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClRedesignSegmentedChoice<CleaningType>(
                  values: CleaningType.values,
                  selected: unit.cleaningType,
                  labelFor: (type) => type.title,
                  onChanged: (type) => setState(() {
                    _roomState = _roomState.setUnitCleaningType(
                      unit.roomType,
                      unit.index,
                      type,
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  bool get _canContinueCurrentStep {
    if (_currentStep == 0 || _currentStep == 1) {
      return _roomState.hasAnyRoom;
    }
    return _roomState.hasAnyRoom;
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;
    _exitDialogOpen = true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('هل تريد مغادرة طلب التنظيف؟'),
        content: const Text(
          'إذا غادرت الآن، ستفقد تقدمك واختيارات الغرف والتفاصيل التي أدخلتها. لن يتم إرسال الطلب.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('متابعة الطلب'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('مغادرة'),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (shouldLeave == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    // Each step starts at its heading, even if the previous screen was scrolled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _bookingScrollController.hasClients) {
        _bookingScrollController.jumpTo(0);
      }
    });
  }

  void _onPrimaryPressed(ClMainBloc bloc, ClMainState state) {
    if (_currentStep == 0 && !_roomState.hasAnyRoom) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد غرفة واحدة على الأقل للتنظيف'),
        ),
      );
      return;
    }
    if (_currentStep < 2) {
      _goToStep(_currentStep + 1);
      return;
    }
    // Do not block the booking journey with an estimate API call.
    // The material catalog is fetched on the dedicated materials step.
    bloc.add(ResetCreateOrderStatusEvent());
    _openScheduleScreen(bloc, null, CleaningType.regularCleaning);
  }

  Future<void> _changeRoomCount(CleaningRoomType roomType, int delta) async {
    final saved = _bookingDraft['bookingV2'];
    if (delta < 0 && saved is CleaningBookingDraft) {
      final roomKey = '${roomType.apiKey}.${_roomState.countFor(roomType)}';
      if (saved.schedules.any((schedule) => schedule.roomKey == roomKey)) {
        final approved = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('إزالة الغرفة؟'),
            content: const Text(
              'ستُحذف مواعيد هذه الغرفة، وسنطلب منك مراجعة مواد وخدمات الفترات المتأثرة.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('إزالة الغرفة'),
              ),
            ],
          ),
        );
        if (!mounted || approved != true) return;
      }
    }
    final next = _roomState.countFor(roomType) + delta;
    setState(() {
      _roomState = _roomState.setCount(roomType, next);
      final keys = _roomState.units.map((unit) => unit.key).toSet();
      _reviewedRoomKeys.removeWhere((key) => !keys.contains(key));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    _didReadArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ClMainHomeDescriptionArgs) {
      _propertyType = args.propertyType;
      _defaultAddress = args.defaultAddress;
      _bloc = args.bloc;
      _bloc?.add(
        SetAssignmentModeEvent(mode: CleaningAssignmentMode.openCount),
      );
    }
  }

  @override
  void dispose() {
    _bookingScrollController.dispose();
    super.dispose();
  }

  final Map<String, dynamic> _bookingDraft = <String, dynamic>{};

  Future<void> _openScheduleScreen(
    ClMainBloc bloc,
    EstimatePriceResponseModel? estimate,
    CleaningType cleaningType,
  ) async {
    final breakdown = _roomSizeBreakdown;
    final leaveBooking = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CleaningBookingV2Screen(
          args: ClMainScheduleArgs(
            propertyType: _propertyType,
            bedrooms: breakdown.legacyBedroomsCount,
            rooms: breakdown.legacyRoomsCount,
            bathrooms: breakdown.legacyBathroomsCount,
            livingRoomSize: breakdown.legacyLivingRoomSize,
            roomSizeBreakdown: breakdown,
            roomCleaningModes: _roomState.roomCleaningModes,
            roomUnits: _roomState.units,
            addressLatitude: _defaultAddress?.latitude ?? 0,
            addressLongitude: _defaultAddress?.longitude ?? 0,
            estimate: estimate,
            cleaningType: cleaningType,
            bloc: bloc,
            defaultAddress: _defaultAddress,
            draft: _bookingDraft,
          ),
        ),
      ),
    );
    if (leaveBooking == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  String _roomTypeLabel(CleaningRoomType type) => switch (type) {
    CleaningRoomType.bedroom => 'غرف النوم',
    CleaningRoomType.bathroom => 'الحمامات',
    CleaningRoomType.kitchen => 'المطبخ',
    CleaningRoomType.livingRoom => 'الصالون / غرفة المعيشة',
    CleaningRoomType.balcony => 'البلكونات',
    CleaningRoomType.corridor => 'الموزع',
    CleaningRoomType.shed => 'السقيفة',
  };

  String _singleRoomLabel(CleaningRoomType type) => switch (type) {
    CleaningRoomType.bedroom => 'غرفة النوم',
    CleaningRoomType.bathroom => 'الحمام',
    CleaningRoomType.kitchen => 'المطبخ',
    CleaningRoomType.livingRoom => 'غرفة المعيشة',
    CleaningRoomType.balcony => 'البلكونة',
    CleaningRoomType.corridor => 'الموزع',
    CleaningRoomType.shed => 'السقيفة',
  };

  String _roomSizeLabel(CleaningRoomSize size) => switch (size) {
    CleaningRoomSize.small => 'صغيرة',
    CleaningRoomSize.medium => 'متوسطة',
    CleaningRoomSize.large => 'كبيرة',
  };

  IconData _roomTypeIcon(CleaningRoomType type) => switch (type) {
    CleaningRoomType.bedroom => Icons.bedroom_parent_outlined,
    CleaningRoomType.bathroom => Icons.bathtub_outlined,
    CleaningRoomType.kitchen => Icons.soup_kitchen_outlined,
    CleaningRoomType.livingRoom => Icons.chair_alt_outlined,
    CleaningRoomType.balcony => Icons.balcony_outlined,
    CleaningRoomType.corridor => Icons.meeting_room_outlined,
    CleaningRoomType.shed => Icons.garage_outlined,
  };
}
