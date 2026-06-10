import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/models/cleaning_gender_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/toast_component.dart';
import '../../data/models/previous_workers_response_model.dart';
import '../../domain/models/cleaning_assignment_mode.dart';
import '../../domain/models/cleaning_room_size_breakdown.dart';
import '../../domain/models/cleaning_type.dart';
import '../../domain/models/cl_worker_room_assignment.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../../domain/usecases/get_previous_cleaning_workers_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/cl_cleaning_type_option_card_widget.dart';
import '../widgets/cl_counter_row_widget.dart';
import '../widgets/cl_home_description_title_card_widget.dart';
import '../widgets/cl_main_continue_button_widget.dart';
import '../widgets/cl_service_assignment_mode_section_widget.dart';
import '../widgets/cl_service_gender_preference_section_widget.dart';
import '../widgets/cl_service_previous_workers_section_widget.dart';
import '../widgets/cl_service_worker_count_selector_widget.dart';
import '../widgets/cl_service_worker_room_assignment_widget.dart';
import '../widgets/home_details_app_bar.dart';
import 'cl_worker_profile_detail_screen.dart';

@AutoRoutePage()
class ClMainHomeDescriptionScreen extends StatefulWidget {
  const ClMainHomeDescriptionScreen({super.key});

  @override
  State<ClMainHomeDescriptionScreen> createState() => _ClMainHomeDescriptionScreenState();
}

class _ClMainHomeDescriptionScreenState extends State<ClMainHomeDescriptionScreen> {
  CleaningRoomSizeBreakdown _roomSizeBreakdown = const CleaningRoomSizeBreakdown();
  CleaningType _selectedCleaningType = CleaningType.regularCleaning;

  String _propertyType = 'apartment';
  ClMainBloc? _bloc;
  bool _didReadArgs = false;
  double? _lastLatitude;
  double? _lastLongitude;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    _didReadArgs = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ClMainHomeDescriptionArgs) {
      _propertyType = args.propertyType;
      _bloc = args.bloc;
      _bloc?.add(GetPreviousCleaningWorkersEvent(params: GetPreviousCleaningWorkersParams(page: 1), isReload: true));
    }
  }

  void _changeRoomBucketCount(CleaningRoomType roomType, CleaningRoomSize roomSize, int delta) {
    final currentCount = _roomSizeBreakdown.countFor(roomType, roomSize);
    setState(() {
      _roomSizeBreakdown = _roomSizeBreakdown.setCount(roomType, roomSize, currentCount + delta);
    });
  }

  List<PreviousWorkerModel> _filterWorkersByGender(
    List<PreviousWorkerModel> workers,
    CleaningGenderPreference preference,
  ) {
    if (preference == CleaningGenderPreference.any) {
      return workers;
    }
    return workers
        .where((worker) => worker.gender == preference)
        .toList(growable: false);
  }

  Future<void> _showLocationPermissionSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إذن الموقع مطلوب'),
        content: const Text('يرجى منح التطبيق إذن الوصول إلى الموقع من إعدادات التطبيق.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppSettings();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLocationServiceSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خدمة الموقع غير مفعّلة'),
        content: const Text('يرجى تفعيل الموقع (GPS) من إعدادات الجهاز ثم الضغط على متابعة مرة أخرى.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await Geolocator.openLocationSettings();
            },
            child: const Text('فتح إعدادات الموقع'),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinuePressed(ClMainBloc bloc, ClMainState state) async {
    if (!_roomSizeBreakdown.hasAnyRoom) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال غرفة واحدة على الأقل قبل المتابعة')));
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (!mounted) return;

    if (permission == LocationPermission.deniedForever) {
      await _showLocationPermissionSettingsDialog();
      return;
    }
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى منح إذن الوصول إلى الموقع للمتابعة')));
      return;
    }

    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      await _showLocationServiceSettingsDialog();
      return;
    }

    Position position;
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر الحصول على الموقع الحالي')));
      return;
    }
    if (!mounted) return;

    _lastLatitude = position.latitude;
    _lastLongitude = position.longitude;

    final roomUnits = enumerateRoomUnits(_roomSizeBreakdown);
    final workerRoomAssignments = buildWorkerRoomAssignmentsJson(
      slotByRoomKey: state.workerRoomAssignments,
      units: roomUnits,
      preferredWorkerId: state.selectedWorkerId,
      assignmentMode: state.assignmentMode,
    );

    bloc.add(
      EstimateCleaningPriceEvent(
        params: EstimateCleaningPriceParams(
          propertyType: _propertyType,
          bedrooms: _roomSizeBreakdown.legacyBedroomsCount,
          rooms: _roomSizeBreakdown.legacyRoomsCount,
          bathrooms: _roomSizeBreakdown.legacyBathroomsCount,
          balconies: _roomSizeBreakdown.legacyBalconiesCount,
          livingRoomSize: _roomSizeBreakdown.legacyLivingRoomSize,
          roomSizeBreakdown: _roomSizeBreakdown,
          cleaningType: _selectedCleaningType,
          addressLatitude: position.latitude,
          addressLongitude: position.longitude,
          assignmentMode: state.assignmentMode,
          numberOfWorkers: state.assignmentMode == CleaningAssignmentMode.openCount ? state.numberOfWorkers : 1,
          preferredWorkerId: state.assignmentMode == CleaningAssignmentMode.preferredWorker ? state.selectedWorkerId : null,
          workerRoomAssignments: workerRoomAssignments.isEmpty ? null : workerRoomAssignments,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const roomTypeOptions = <({CleaningRoomType type, String title, IconData icon})>[
      (type: CleaningRoomType.bedroom, title: 'غرف النوم', icon: Icons.bedroom_parent_outlined),
      (type: CleaningRoomType.bathroom, title: 'الحمامات', icon: Icons.bathtub_outlined),
      (type: CleaningRoomType.kitchen, title: 'المطابخ', icon: Icons.soup_kitchen_outlined),
      (type: CleaningRoomType.livingRoom, title: 'الصالون / غرفة المعيشة', icon: Icons.chair_alt_outlined),
      (type: CleaningRoomType.balcony, title: 'البلكونات', icon: Icons.balcony_outlined),
      (type: CleaningRoomType.corridor, title: 'الموزع', icon: Icons.meeting_room_outlined),
    ];

    const sizeOptions = <({CleaningRoomSize size, String label})>[
      (size: CleaningRoomSize.small, label: 'صغير'),
      (size: CleaningRoomSize.medium, label: 'متوسط'),
      (size: CleaningRoomSize.large, label: 'كبير'),
    ];

    final bloc = _bloc ?? getIt<ClMainBloc>();
    final roomUnits = enumerateRoomUnits(_roomSizeBreakdown);
    final maxWorkers = _roomSizeBreakdown.totalUnits;
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<ClMainBloc, ClMainState>(
        listenWhen: (previous, current) => previous.estimatePriceStatus != current.estimatePriceStatus,
        listener: (context, state) {
          if (state.estimatePriceStatus == BlocStatus.loading) {
            Loading.show(context);
          } else if (state.estimatePriceStatus == BlocStatus.success && state.estimatePrice != null) {
            Loading.close();
            context.pushRoute(
              '/clmainserviceschedule',
              arguments: ClMainScheduleArgs(
                propertyType: _propertyType,
                bedrooms: _roomSizeBreakdown.legacyBedroomsCount,
                rooms: _roomSizeBreakdown.legacyRoomsCount,
                bathrooms: _roomSizeBreakdown.legacyBathroomsCount,
                livingRoomSize: _roomSizeBreakdown.legacyLivingRoomSize,
                roomSizeBreakdown: _roomSizeBreakdown,
                addressLatitude: _lastLatitude ?? 0,
                addressLongitude: _lastLongitude ?? 0,
                estimate: state.estimatePrice!,
                cleaningType: _selectedCleaningType,
                bloc: bloc,
              ),
            );
          } else {
            Loading.close();
            ToastComponent.showToast(context, msg: state.errorMessage ?? 'حدث خطأ أثناء حساب التكلفة');
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF2F2F2),
            body: SafeArea(
              child: Column(
                children: [
                  const HomeDetailsAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        children: [
                          ClHomeDescriptionTitleCardWidget(
                            step: 1,
                            title: 'حجم الغرف لكل نوع في المنزل',
                            subtitle: 'أدخل عدد الغرف الصغيرة والمتوسطة والكبيرة لكل نوع',
                            child: Column(
                              children: [
                                ...roomTypeOptions.map((option) {
                                  final total = _roomSizeBreakdown.totalForType(option.type);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(option.icon, size: 20, color: const Color(0xFF0CBBC7)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: AppText.bodyMedium(option.title, fontWeight: FontWeight.w700, textAlign: TextAlign.start),
                                            ),
                                            Container(
                                              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(color: const Color(0xFF0CBBC7).withAlpha(26), borderRadius: BorderRadius.circular(999)),
                                              child: AppText.labelMedium('المجموع: $total', color: const Color(0xFF0B7480), fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        ...sizeOptions.map((sizeOption) {
                                          final value = _roomSizeBreakdown.countFor(option.type, sizeOption.size);
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: ClCounterRowWidget(
                                              label: 'حجم ${sizeOption.label}',
                                              value: value,
                                              icon: option.icon,
                                              onIncrement: () => _changeRoomBucketCount(option.type, sizeOption.size, 1),
                                              onDecrement: () => _changeRoomBucketCount(option.type, sizeOption.size, -1),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClHomeDescriptionTitleCardWidget(
                            step: 2,
                            title: 'نوع التنظيف',
                            subtitle: 'اختر نوع التنظيف المناسب لمنزلك',
                            child: Column(
                              children: [
                                ClCleaningTypeOptionCardWidget(
                                  title: CleaningType.deepCleaning.title,
                                  subtitle: CleaningType.deepCleaning.subtitle,
                                  isSelected: _selectedCleaningType == CleaningType.deepCleaning,
                                  onTap: () => setState(() => _selectedCleaningType = CleaningType.deepCleaning),
                                ),
                                const SizedBox(height: 10),
                                ClCleaningTypeOptionCardWidget(
                                  title: CleaningType.regularCleaning.title,
                                  subtitle: CleaningType.regularCleaning.subtitle,
                                  isSelected: _selectedCleaningType == CleaningType.regularCleaning,
                                  onTap: () => setState(() => _selectedCleaningType = CleaningType.regularCleaning),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClServiceAssignmentModeSectionWidget(
                            selectedMode: state.assignmentMode,
                            onModeChanged: (mode) {
                              bloc.add(SetAssignmentModeEvent(mode: mode));
                            },
                          ),
                          const SizedBox(height: 10),
                          if (state.assignmentMode == CleaningAssignmentMode.openCount) ...[
                            ClServiceWorkerCountSelectorWidget(
                              count: state.numberOfWorkers,
                              maxCount: maxWorkers,
                              onChanged: (count) {
                                bloc.add(SetNumberOfWorkersEvent(count: count));
                              },
                            ),
                            const SizedBox(height: 10),
                            ClServiceWorkerRoomAssignmentWidget(
                              units: roomUnits,
                              numberOfWorkers: state.numberOfWorkers,
                              slotByRoomKey: state.workerRoomAssignments,
                              fieldErrors: state.assignmentFieldErrors,
                              submittedAssignments: buildWorkerRoomAssignmentsJson(
                                slotByRoomKey: state.workerRoomAssignments,
                                units: roomUnits,
                                preferredWorkerId: state.selectedWorkerId,
                                assignmentMode: state.assignmentMode,
                              ),
                              onAssign: (roomKey, workerSlot) {
                                bloc.add(SetWorkerRoomSlotEvent(roomKey: roomKey, workerSlot: workerSlot));
                              },
                            ),
                            const SizedBox(height: 10),
                          ] else ...[
                            ClServiceGenderPreferenceSectionWidget(
                              selectedPreference: state.genderPreference,
                              onChanged: (value) {
                                bloc.add(
                                  SetGenderPreferenceEvent(preference: value),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            ClServicePreviousWorkersSectionWidget(
                              workers: _filterWorkersByGender(
                                state.previousWorkers.list,
                                state.genderPreference,
                              ),
                              selectedWorkerId: state.selectedWorkerId,
                              isLoading: state.previousWorkersStatus == BlocStatus.loading,
                              errorMessage: state.previousWorkersStatus == BlocStatus.failed ? state.errorMessage : null,
                              onSelectWorker: (workerId) {
                                bloc.add(SetPreferredWorkerEvent(workerId: workerId));
                              },
                              onOpenWorkerProfile: (worker) {
                                context.pushRoute('/clworkerprofiledetail', arguments: WorkerProfileRouteArgs.fromPreviousWorker(worker));
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                          ClMainContinueButtonWidget(
                            onPressed: () {
                              _onContinuePressed(context.read<ClMainBloc>(), state);
                            },
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
