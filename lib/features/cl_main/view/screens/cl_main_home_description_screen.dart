import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../profile/domain/models/address_list_item.dart';
import '../../domain/models/cl_worker_room_assignment.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import '../../domain/models/cleaning_progressive_room_state.dart';
import '../../domain/models/cleaning_room_size_breakdown.dart';
import '../../domain/models/cleaning_type.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/cl_cleaning_type_option_card_widget.dart';
import '../widgets/cl_redesign_components.dart';
import '../widgets/home_details_app_bar.dart';
import 'cl_main_service_schedule_screen.dart';

@AutoRoutePage()
class ClMainHomeDescriptionScreen extends StatefulWidget {
  const ClMainHomeDescriptionScreen({super.key});

  @override
  State<ClMainHomeDescriptionScreen> createState() =>
      _ClMainHomeDescriptionScreenState();
}

class _ClMainHomeDescriptionScreenState
    extends State<ClMainHomeDescriptionScreen> {
  static const _primaryRoomTypes = <CleaningRoomType>[
    CleaningRoomType.bedroom,
    CleaningRoomType.bathroom,
    CleaningRoomType.kitchen,
    CleaningRoomType.livingRoom,
  ];

  static const _extraRoomTypes = <CleaningRoomType>[
    CleaningRoomType.balcony,
    CleaningRoomType.corridor,
    CleaningRoomType.shed,
  ];

  CleaningProgressiveRoomState _roomState =
      const CleaningProgressiveRoomState();
  CleaningType? _selectedCleaningType;
  int _currentStep = 0;
  bool _showExtraSpaces = false;

  String _propertyType = 'apartment';
  AddressListItem? _defaultAddress;
  ClMainBloc? _bloc;
  bool _didReadArgs = false;
  bool _isLoadingOverlayVisible = false;
  bool _isEstimatingForContinue = false;

  CleaningRoomSizeBreakdown get _roomSizeBreakdown => _roomState.toBreakdown();

  @override
  Widget build(BuildContext context) {
    final bloc = _bloc ?? getIt<ClMainBloc>();
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<ClMainBloc, ClMainState>(
        listenWhen: (previous, current) =>
            previous.estimatePriceStatus != current.estimatePriceStatus,
        listener: (context, state) => _listenToEstimate(bloc, state),
        builder: (context, state) {
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
                          child: _buildStep(state),
                        ),
                      ),
                    ),
                    ClRedesignStickyActions(
                      primaryLabel: _currentStep == 2
                          ? 'اختيار الموعد والعنوان'
                          : 'التالي',
                      onPrimary: () => _onPrimaryPressed(bloc, state),
                      primaryEnabled: _canContinueCurrentStep,
                      secondaryLabel: _currentStep > 0 ? 'السابق' : null,
                      onSecondary: _currentStep > 0
                          ? () => setState(() => _currentStep--)
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

  Widget _buildStep(ClMainState state) {
    return switch (_currentStep) {
      0 => _buildRoomCountsStep(),
      1 => _buildRoomSizesStep(),
      _ => _buildCleaningTypeStep(),
    };
  }

  Widget _buildRoomCountsStep() {
    final visibleTypes = <CleaningRoomType>[
      ..._primaryRoomTypes,
      if (_showExtraSpaces) ..._extraRoomTypes,
    ];
    return Column(
      key: const ValueKey('room_counts_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ClRedesignStepHeader(
          currentStep: 1,
          totalSteps: 3,
          title: 'كم مساحة تريد تنظيفها؟',
          subtitle:
              'حدد عدد الغرف أولاً، وسنطلب حجم كل غرفة في الخطوة التالية.',
        ),
        const SizedBox(height: 20),
        for (final type in visibleTypes) ...[
          ClRedesignCounter(
            key: Key('room_count_${type.apiKey}'),
            label: _roomTypeLabel(type),
            icon: _roomTypeIcon(type),
            value: _roomState.countFor(type),
            onIncrement: () => _changeRoomCount(type, 1),
            onDecrement: () => _changeRoomCount(type, -1),
          ),
          const SizedBox(height: 10),
        ],
        TextButton.icon(
          onPressed: () => setState(() => _showExtraSpaces = !_showExtraSpaces),
          icon: Icon(_showExtraSpaces ? Icons.expand_less : Icons.add),
          label: Text(
            _showExtraSpaces ? 'إخفاء المساحات الإضافية' : 'إضافة مساحة أخرى',
          ),
        ),
      ],
    );
  }

  Widget _buildRoomSizesStep() {
    return Column(
      key: const ValueKey('room_sizes_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ClRedesignStepHeader(
          currentStep: 2,
          totalSteps: 3,
          title: 'ما حجم كل غرفة؟',
          subtitle:
              'اختر الحجم الأقرب لكل مساحة. يمكنك الرجوع وتعديل الأعداد دون فقدان الاختيارات.',
        ),
        const SizedBox(height: 20),
        for (final unit in _roomState.units) ...[
          ClRedesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${_singleRoomLabel(unit.roomType)} ${unit.index}',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 12),
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
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildCleaningTypeStep() {
    return Column(
      key: const ValueKey('cleaning_type_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ClRedesignStepHeader(
          currentStep: 3,
          totalSteps: 3,
          title: 'اختر نوع التنظيف',
          subtitle:
              'يمكنك إضافة الخدمات الإضافية والمواد لاحقاً قبل تأكيد الطلب.',
        ),
        const SizedBox(height: 20),
        ClCleaningTypeOptionCardWidget(
          title: CleaningType.regularCleaning.title,
          subtitle: CleaningType.regularCleaning.subtitle,
          isSelected: _selectedCleaningType == CleaningType.regularCleaning,
          onTap: () => setState(
            () => _selectedCleaningType = CleaningType.regularCleaning,
          ),
        ),
        const SizedBox(height: 12),
        ClCleaningTypeOptionCardWidget(
          title: CleaningType.deepCleaning.title,
          subtitle: CleaningType.deepCleaning.subtitle,
          isSelected: _selectedCleaningType == CleaningType.deepCleaning,
          onTap: () =>
              setState(() => _selectedCleaningType = CleaningType.deepCleaning),
        ),
        const SizedBox(height: 16),
        const ClRedesignCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Color(0xFF0F8E98)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'اختيار العمال، توزيع الغرف، الموعد، العنوان والإضافات سيتم لاحقاً حتى يبقى الحجز بسيطاً وواضحاً.',
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Color(0xFF475467), height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool get _canContinueCurrentStep {
    if (_currentStep == 0) return true;
    if (_currentStep == 1) return true;
    return !_isEstimatingForContinue;
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
      setState(() => _currentStep++);
      return;
    }
    if (_selectedCleaningType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار نوع التنظيف قبل المتابعة')),
      );
      return;
    }
    _estimateAndContinue(bloc, state);
  }

  void _changeRoomCount(CleaningRoomType roomType, int delta) {
    final next = _roomState.countFor(roomType) + delta;
    setState(() {
      _roomState = _roomState.setCount(roomType, next);
    });
  }

  void _listenToEstimate(ClMainBloc bloc, ClMainState state) {
    if (!_isEstimatingForContinue) return;
    if (state.estimatePriceStatus == BlocStatus.loading) {
      _showLoadingOverlay();
      return;
    }
    if (state.estimatePriceStatus == BlocStatus.success &&
        state.estimatePrice != null) {
      final cleaningType = _selectedCleaningType;
      _isEstimatingForContinue = false;
      _closeLoadingOverlay();
      if (cleaningType == null) return;
      _openScheduleScreen(bloc, state.estimatePrice!, cleaningType);
      return;
    }
    if (state.estimatePriceStatus == BlocStatus.failed) {
      _isEstimatingForContinue = false;
      _closeLoadingOverlay();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'حدث خطأ أثناء حساب التكلفة'),
        ),
      );
    }
  }

  void _estimateAndContinue(ClMainBloc bloc, ClMainState state) {
    if (_isEstimatingForContinue || !_roomState.hasAnyRoom) return;

    final breakdown = _roomSizeBreakdown;
    final address = _defaultAddress;
    final roomUnits = enumerateRoomUnits(breakdown);
    final workerRoomAssignments = buildWorkerRoomAssignmentsJson(
      slotByRoomKey: state.workerRoomAssignments,
      units: roomUnits,
      preferredWorkerId: state.primarySelectedWorkerId,
      assignmentMode: state.assignmentMode,
    );

    _isEstimatingForContinue = true;
    // A shared ClMainBloc can still contain the success/result of the
    // previous booking. Clear it before starting a new estimate so opening
    // the schedule cannot replay the previous order success.
    bloc.add(ResetCreateOrderStatusEvent());
    bloc.add(
      EstimateCleaningPriceEvent(
        params: EstimateCleaningPriceParams(
          propertyType: _propertyType,
          bedrooms: breakdown.legacyBedroomsCount,
          rooms: breakdown.legacyRoomsCount,
          bathrooms: breakdown.legacyBathroomsCount,
          balconies: breakdown.legacyBalconiesCount,
          livingRoomSize: breakdown.legacyLivingRoomSize,
          roomSizeBreakdown: breakdown,
          cleaningType: _selectedCleaningType!,
          addressId: int.tryParse(address?.id ?? ''),
          addressLatitude: address?.latitude,
          addressLongitude: address?.longitude,
          assignmentMode: state.assignmentMode,
          numberOfWorkers:
              state.assignmentMode == CleaningAssignmentMode.openCount
              ? state.numberOfWorkers
              : (state.selectedWorkerIds.length > 1
                    ? state.selectedWorkerIds.length
                    : 1),
          preferredWorkerIds: state.selectedWorkerIds,
          workerRoomAssignments: workerRoomAssignments.isEmpty
              ? null
              : workerRoomAssignments,
        ),
      ),
    );
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
    _closeLoadingOverlay();
    super.dispose();
  }

  void _openScheduleScreen(
    ClMainBloc bloc,
    EstimatePriceResponseModel estimate,
    CleaningType cleaningType,
  ) {
    final breakdown = _roomSizeBreakdown;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClMainServiceScheduleScreen(
          args: ClMainScheduleArgs(
            propertyType: _propertyType,
            bedrooms: breakdown.legacyBedroomsCount,
            rooms: breakdown.legacyRoomsCount,
            bathrooms: breakdown.legacyBathroomsCount,
            livingRoomSize: breakdown.legacyLivingRoomSize,
            roomSizeBreakdown: breakdown,
            addressLatitude: _defaultAddress?.latitude ?? 0,
            addressLongitude: _defaultAddress?.longitude ?? 0,
            estimate: estimate,
            cleaningType: cleaningType,
            bloc: bloc,
            defaultAddress: _defaultAddress,
          ),
        ),
      ),
    );
  }

  void _showLoadingOverlay() {
    if (_isLoadingOverlayVisible || !mounted) return;
    _isLoadingOverlayVisible = true;
    Loading.show(context);
  }

  void _closeLoadingOverlay() {
    if (!_isLoadingOverlayVisible) return;
    _isLoadingOverlayVisible = false;
    Loading.close();
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
