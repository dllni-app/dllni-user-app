import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/toast_component.dart';
import '../../domain/usecases/estimate_cleaning_price_use_case.dart';
import '../data/cl_main_route_args.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../widgets/cl_counter_row_widget.dart';
import '../widgets/cl_home_description_title_card_widget.dart';
import '../widgets/cl_main_continue_button_widget.dart';
import '../widgets/cl_option_tile_widget.dart';
import '../widgets/home_details_app_bar.dart';

@AutoRoutePage()
class ClMainHomeDescriptionScreen extends StatefulWidget {
  const ClMainHomeDescriptionScreen({super.key});

  @override
  State<ClMainHomeDescriptionScreen> createState() => _ClMainHomeDescriptionScreenState();
}

class _ClMainHomeDescriptionScreenState extends State<ClMainHomeDescriptionScreen> {
  int bedroomsCount = 1;
  int bathroomsCount = 1;
  int roomsCount = 1;
  int kitchenCount = 1;

  String selectedLivingRoomOption = '';
  String selectedHeadboardOption = '';
  String _propertyType = 'apartment';
  ClMainBloc? _bloc;
  bool _didReadArgs = false;

  bool get _hideBedroomsCountRow =>
      _propertyType == 'studio' || _propertyType == 'office';
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
    }
  }

  void _selectLivingRoomOption(String key, bool isSelected) {
    setState(() {
      selectedLivingRoomOption = isSelected ? key : '';
    });
  }

  void _selectHeadboardOption(String key, bool isSelected) {
    setState(() {
      selectedHeadboardOption = isSelected ? key : '';
    });
  }

  Future<void> _showLocationPermissionSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إذن الموقع مطلوب'),
        content: const Text('يُرجى منح التطبيق إذن الوصول إلى الموقع من إعدادات التطبيق.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
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
        content: const Text('يُرجى تفعيل الموقع (GPS) من إعدادات الجهاز ثم الضغط على متابعة مرة أخرى.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
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

  Future<void> _onContinuePressed(ClMainBloc bloc) async {
    if (selectedLivingRoomOption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار حجم الغرفة قبل المتابعة')));
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يُرجى منح إذن الوصول إلى الموقع للمتابعة')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر الحصول على الموقع الحالي')),
      );
      return;
    }
    if (!mounted) return;

    _lastLatitude = position.latitude;
    _lastLongitude = position.longitude;

    bloc.add(
      EstimateCleaningPriceEvent(
        params: EstimateCleaningPriceParams(
          propertyType: _propertyType,
          bedrooms: bedroomsCount,
          rooms: roomsCount,
          bathrooms: bathroomsCount,
          livingRoomSize: selectedLivingRoomOption,
          addressLatitude: position.latitude,
          addressLongitude: position.longitude,
          preferredWorkerId: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const livingRoomOptions = <({String key, String title, String subtitle})>[
      (key: 'small', title: 'صغيرة', subtitle: 'يجلس 3 - 4 أشخاص'),
      (key: 'medium', title: 'كبيرة', subtitle: 'يجلس 5 - 8 أشخاص'),
      (key: 'large', title: 'كبيرة جداً', subtitle: 'يجلس 9 فما فوق'),
    ];
    const headboardOptions = <({String key, String title})>[
      (key: 'regular', title: 'لا يوحد تراس'),
      (key: 'small', title: 'تراس صغير'),
      (key: 'big', title: 'تراس كبير'),
    ];

    final bloc = _bloc ?? getIt<ClMainBloc>();
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
                bedrooms: bedroomsCount,
                rooms: roomsCount,
                bathrooms: bathroomsCount,
                livingRoomSize: selectedLivingRoomOption,
                addressLatitude: _lastLatitude ?? 0,
                addressLongitude: _lastLongitude ?? 0,
                estimate: state.estimatePrice!,
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
                  HomeDetailsAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        children: [
                          ClHomeDescriptionTitleCardWidget(
                            step: 1,
                            title: 'تحديد عدد الغرف',
                            subtitle: 'هذا سيساعدنا على تحديد المساحة التقريبية للعمل',
                            child: Column(
                              spacing: 12,
                              children: [
                                ClCounterRowWidget(
                                  label: 'عدد الغرف',
                                  value: bedroomsCount,
                                  icon: Icons.meeting_room,
                                  onIncrement: () => setState(() => bedroomsCount++),
                                  onDecrement: () => setState(() => bedroomsCount = (bedroomsCount > 1) ? bedroomsCount - 1 : 1),
                                ),
                                ClCounterRowWidget(
                                  label: 'عدد الحمامات',
                                  value: bathroomsCount,
                                  icon: Icons.bathtub_outlined,
                                  onIncrement: () => setState(() => bathroomsCount++),
                                  onDecrement: () => setState(() => bathroomsCount = (bathroomsCount > 1) ? bathroomsCount - 1 : 1),
                                ),
                                if (!_hideBedroomsCountRow)
                                  ClCounterRowWidget(
                                    label: 'عدد غرف النوم',
                                    value: roomsCount,
                                    icon: Icons.home_work_outlined,
                                    onIncrement: () => setState(() => roomsCount++),
                                    onDecrement: () => setState(() => roomsCount = (roomsCount > 1) ? roomsCount - 1 : 1),
                                  ),
                                ClCounterRowWidget(
                                  label: 'عدد المطابخ',
                                  value: kitchenCount,
                                  icon: Icons.home_work_outlined,
                                  onIncrement: () => setState(() => kitchenCount++),
                                  onDecrement: () => setState(() => kitchenCount = (kitchenCount > 1) ? kitchenCount - 1 : 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClHomeDescriptionTitleCardWidget(
                            step: 2,
                            title: 'وصف تقريبي لحجم الغرف',
                            subtitle: 'اختر نوع أقرب وصف لحجم الغرفة',
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                ...livingRoomOptions.map(
                                  (option) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ClOptionTileWidget(
                                      title: option.title,
                                      subtitle: option.subtitle,
                                      value: selectedLivingRoomOption == option.key,
                                      onChanged: (selected) => _selectLivingRoomOption(option.key, selected),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClHomeDescriptionTitleCardWidget(
                            step: 3,
                            title: 'تحديد حجم التراس',
                            subtitle: 'حدد حجم التراس في حال وجوده',
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: headboardOptions.length,
                              itemBuilder: (context, index) {
                                final option = headboardOptions[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: index == headboardOptions.length - 1 ? 0 : 8),
                                  child: ClOptionTileWidget(
                                    title: option.title,
                                    value: selectedHeadboardOption == option.key,
                                    onChanged: (selected) => _selectHeadboardOption(option.key, selected),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClMainContinueButtonWidget(
                            onPressed: () {
                              _onContinuePressed(context.read<ClMainBloc>());
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
