import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/helpers/phone_number_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:latlong2/latlong.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/session/user_session_keys.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../auth/data/models/login_response_model.dart';
import '../../domain/models/address_list_item.dart';
import '../../domain/services/user_location_service.dart';
import '../../domain/usecases/create_address_use_case.dart';
import '../../domain/usecases/update_address_use_case.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/filled_text_field.dart';
import '../widgets/numbered_section_card.dart';
import '../widgets/personal_details_app_bar.dart';

Future<List<String>> getNeighborhoods([String city = 'حلب']) async {
  final dioNetwork = getIt<DioNetwork>();
  final response = await dioNetwork.getData(
    endPoint: '/api/v1/cleaning/neighborhoods',
    params: {'city': city},
  );
  final responseBody = response.data;
  if (responseBody is! Map<String, dynamic>) {
    return const <String>[];
  }

  final List<dynamic> neighborhoodsList = responseBody['data'] ?? [];
  return neighborhoodsList
      .map((item) {
        if (item is Map<String, dynamic>) {
          return (item['displayName'] ?? item['nameAr'] ?? item['nameEn'] ?? '')
              .toString()
              .trim();
        }
        return '';
      })
      .where((name) => name.isNotEmpty)
      .toList(growable: false);
}

@AutoRoutePage()
class AddAddressScreen extends StatefulWidget {
  final MyAddressesScreenParams params;

  const AddAddressScreen({super.key, required this.params});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class CreatedAddressSelectionHint {
  final String label;
  final String mobile;
  final String city;
  final String neighborhood;
  final String street;
  final String floor;
  final double latitude;
  final double longitude;
  final String? building;
  final String? directions;

  const CreatedAddressSelectionHint({
    required this.label,
    required this.mobile,
    required this.city,
    required this.neighborhood,
    required this.street,
    required this.floor,
    required this.latitude,
    required this.longitude,
    this.building,
    this.directions,
  });
}

class MyAddressesScreenParams {
  final ProfileBloc bloc;
  final AddressListItem? addressItem;
  final bool selectMode;

  MyAddressesScreenParams({
    required this.bloc,
    this.addressItem,
    this.selectMode = false,
  });
}

class AddAddressBottomActions extends StatelessWidget {
  const AddAddressBottomActions({
    required this.isSubmitting,
    required this.submitLabel,
    required this.onSubmitPressed,
    required this.onCancelPressed,
    super.key,
  });

  static const double stackedBreakpoint = 320;
  static const Key submitButtonKey = Key('add_address_submit_button');
  static const Key cancelButtonKey = Key('add_address_cancel_button');

  final bool isSubmitting;
  final String submitLabel;
  final VoidCallback? onSubmitPressed;
  final VoidCallback onCancelPressed;

  @override
  Widget build(BuildContext context) {
    final submitButton = SizedBox(
      height: 42,
      child: ElevatedButton(
        key: submitButtonKey,
        onPressed: isSubmitting ? null : onSubmitPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: context.primary,
          foregroundColor: context.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size.fromHeight(42),
        ),
        child: AppText.labelLarge(
          submitLabel,
          color: context.onPrimary,
          fontWeight: FontWeight.w700,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    final cancelButton = SizedBox(
      height: 42,
      child: OutlinedButton(
        key: cancelButtonKey,
        onPressed: isSubmitting ? null : onCancelPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size.fromHeight(42),
        ),
        child: AppText.labelLarge(
          'إلغاء',
          color: context.error,
          fontWeight: FontWeight.w700,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < stackedBreakpoint) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [submitButton, const SizedBox(height: 10), cancelButton],
          );
        }

        return Row(
          children: [
            Expanded(flex: 2, child: submitButton),
            const SizedBox(width: 12),
            Expanded(child: cancelButton),
          ],
        );
      },
    );
  }
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController(text: 'حلب');
  String? _selectedNeighborhood;
  final _directionsController = TextEditingController();
  final _phoneController = TextEditingController();
  List<String> _neighborhoods = [];

  String _selectedType = 'المنزل';
  bool _isDefault = true;

  double? _latitude;
  double? _longitude;

  bool get _hasSelectedLocation => _latitude != null && _longitude != null;
  bool get _isEditMode => widget.params.addressItem != null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      bloc: widget.params.bloc,
      listenWhen: (previous, current) =>
          previous.createAddressStatus != current.createAddressStatus ||
          previous.updateAddressStatus != current.updateAddressStatus,
      listener: (context, state) {
        final isCreateSuccess = state.createAddressStatus == BlocStatus.success;
        final isUpdateSuccess = state.updateAddressStatus == BlocStatus.success;
        final isCreateFailure = state.createAddressStatus == BlocStatus.failed;
        final isUpdateFailure = state.updateAddressStatus == BlocStatus.failed;
        final isCreating = state.createAddressStatus == BlocStatus.loading;
        final isUpdating = state.updateAddressStatus == BlocStatus.loading;

        if (isCreateSuccess) {
          Loading.close();
          if (widget.params.selectMode) {
            context.pop(_buildCreatedAddressHint());
          } else {
            context.pop(true);
          }
        } else if (isUpdateSuccess) {
          Loading.close();
          context.pop(true);
        } else if (isCreateFailure || isUpdateFailure) {
          Loading.close();
          AppToast.showToast(
            context: context,
            message:
                state.errorMessage ??
                (_isEditMode ? 'خطأ في تعديل العنوان' : 'خطأ في إضافة العنوان'),
            type: ToastificationType.error,
          );
        } else if (isCreating || isUpdating) {
          Loading.show(context);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xffF9FAFB),
        body: SafeArea(
          child: Column(
            children: [
              PersonalDetailsAppBar(
                title: _isEditMode ? 'تعديل العنوان' : 'إضافة عنوان جديد',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 132),
                  child: Form(
                    key: _formKey,
                    child: NumberedSectionCard(
                      sectionNumber: '1',
                      title: 'المعلومات الأساسية',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AddressTypeSelector(
                            value: _selectedType,
                            onChanged: (value) =>
                                setState(() => _selectedType = value),
                          ),
                          const SizedBox(height: 12),
                          FilledPhoneNumberField(
                            label: 'رقم الجوال',
                            isRequired: false,
                            hintText: 'أدخل رقم الجوال المرتبط بالعنوان',
                            controller: _phoneController,
                            obscureText: false,
                            readOnly: false,
                            hasError: false,
                            onChanged: (phone) => _phoneController.text = phone,
                            keyboardType: TextInputType.phone,
                            suffixIcon: const Icon(Icons.phone),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _pickAddressFromMap,
                            icon: const Icon(Icons.map_outlined),
                            label: Text(
                              _hasSelectedLocation
                                  ? 'تعديل الموقع على الخريطة'
                                  : 'تحديد العنوان من الخريطة',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (_hasSelectedLocation) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Lat: ${_latitude!.toStringAsFixed(6)}  •  Lng: ${_longitude!.toStringAsFixed(6)}',
                              style: const TextStyle(
                                color: Color(0xff6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppText.bodyMedium(
                                    'المدينة',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  AppText.bodyMedium(
                                    '*',
                                    color: context.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                key: const Key('address_city_dropdown'),
                                initialValue: _cityController.text,
                                decoration: InputDecoration(
                                  hintText: 'اختر المدينة',
                                  hintStyle: const TextStyle(
                                    color: AppColors.hintText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xffF9FAFB),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xffE5E7EB),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xffE5E7EB),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: context.primary,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem<String>(
                                    value: 'حلب',
                                    child: Text('حلب'),
                                  ),
                                ],
                                validator: _requiredCityValidator,
                                onChanged: (value) {
                                  if (value == null) return;
                                  _cityController.text = value;
                                  unawaited(_loadNeighborhoods(city: value));
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppText.bodyMedium(
                                    'الحي',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  AppText.bodyMedium(
                                    '*',
                                    color: context.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue:
                                    _selectedNeighborhood?.isEmpty ?? true
                                    ? null
                                    : _selectedNeighborhood,
                                decoration: InputDecoration(
                                  hintText: 'اختر الحي',
                                  hintStyle: const TextStyle(
                                    color: AppColors.hintText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xffF9FAFB),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xffE5E7EB),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xffE5E7EB),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: context.primary,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                                items: _neighborhoods
                                    .map(
                                      (item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(item),
                                      ),
                                    )
                                    .toList(),
                                validator: _requiredNeighborhoodValidator,
                                onChanged: (value) => setState(
                                  () => _selectedNeighborhood = value ?? '',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'تفاصيل أخرى',
                            isRequired: true,
                            hintText:
                                'مثل: جانب الصيدلية طابق اول اول باب على اليسار, الخ....',
                            controller: _directionsController,
                            validator: _requiredDirectionsValidator,
                            onTap: () =>
                                _moveCursorToTextEnd(_directionsController),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: AppText.bodyMedium('تعيين كعنوان افتراضي'),
                            value: _isDefault,
                            onChanged: (value) =>
                                setState(() => _isDefault = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsetsDirectional.fromSTEB(
                  20,
                  8,
                  20,
                  12 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: SafeArea(
                  top: false,
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    bloc: widget.params.bloc,
                    builder: (context, state) {
                      final isSubmitting =
                          state.createAddressStatus == BlocStatus.loading ||
                          state.updateAddressStatus == BlocStatus.loading;
                      return AddAddressBottomActions(
                        isSubmitting: isSubmitting,
                        submitLabel: _isEditMode
                            ? 'حفظ التعديلات'
                            : 'أضف العنوان',
                        onSubmitPressed: _submitAddress,
                        onCancelPressed: () => context.pop(false),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _directionsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_validateLocationBeforeSubmit()) {
      return;
    }

    final phoneText = _phoneController.text.trim();
    var mobile = '';
    if (phoneText.isNotEmpty) {
      final formatted = formatPhoneForApi(
        PhoneNumber(phoneNumber: phoneText, dialCode: '963', isoCode: 'SY'),
      );
      if (formatted == null) {
        AppToast.showToast(
          context: context,
          message: 'يرجى إدخال رقم جوال صالح أو تركه فارغًا',
          type: ToastificationType.error,
        );
        return;
      }
      mobile = formatted;
    }

    if (_isEditMode) {
      final addressId = int.tryParse(widget.params.addressItem!.id);
      if (addressId == null) {
        AppToast.showToast(
          context: context,
          message: 'معرف العنوان غير صالح',
          type: ToastificationType.error,
        );
        return;
      }
      widget.params.bloc.add(
        UpdateAddressEvent(
          params: UpdateAddressParams(
            addressId: addressId,
            label: _selectedType,
            mobile: mobile,
            city: _cityController.text.trim(),
            neighborhood: _selectedNeighborhood ?? '',
            street: '',
            building: '',
            floor: '',
            directions: _directionsController.text.trim(),
            isDefault: _isDefault,
            latitude: _latitude,
            longitude: _longitude,
          ),
        ),
      );
      return;
    }

    widget.params.bloc.add(
      CreateAddressEvent(
        params: CreateAddressParams(
          label: _selectedType,
          mobile: mobile,
          city: _cityController.text.trim(),
          neighborhood: _selectedNeighborhood ?? '',
          street: '',
          building: null,
          floor: '',
          directions: _directionsController.text.trim(),
          isDefault: _isDefault,
          latitude: _latitude!,
          longitude: _longitude!,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final item = widget.params.addressItem;
    unawaited(_loadNeighborhoods(city: 'حلب'));
    if (item == null) {
      final json = SharedPreferencesHelper.getData(
        key: UserSessionKeys.loggedInUser,
      );
      final user = LoggedInUserModel.fromJson(jsonDecode(json));
      _phoneController.text = user.phone ?? '';
    } else {
      _phoneController.text = item.mobile ?? '';
      _selectedNeighborhood = item.neighborhood ?? '';
      _directionsController.text = item.directions ?? item.landmark ?? '';
      _isDefault = item.isDefault;
      _latitude = item.latitude;
      _longitude = item.longitude;
      _selectedType = switch (item.type) {
        AddressType.work => 'العمل',
        AddressType.family => 'العائلة',
        AddressType.home => 'المنزل',
      };
    }
    _phoneController.text = _phoneController.text.replaceAll('+963', '');
  }

  Future<void> _loadNeighborhoods({String city = 'حلب'}) async {
    try {
      final neighborhoods = await getNeighborhoods(city);
      if (!mounted) return;
      setState(() {
        _neighborhoods = neighborhoods;
        final selected = _selectedNeighborhood;
        if (selected != null &&
            selected.isNotEmpty &&
            !_neighborhoods.contains(selected)) {
          _neighborhoods = [..._neighborhoods, selected];
        }
      });
    } catch (error) {
      log('error: $error');
      if (!mounted) return;
      AppToast.showToast(
        context: context,
        message: 'خطأ في جلب الأحياء ${error.toString()}',
        type: ToastificationType.error,
      );
    }
  }

  CreatedAddressSelectionHint _buildCreatedAddressHint() {
    return CreatedAddressSelectionHint(
      label: '',
      mobile: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      neighborhood: _selectedNeighborhood ?? '',
      street: '',
      floor: '',
      latitude: _latitude!,
      longitude: _longitude!,
      building: null,
      directions: _directionsController.text.trim().isEmpty
          ? null
          : _directionsController.text.trim(),
    );
  }

  void _moveCursorToTextEnd(TextEditingController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final textLength = controller.text.length;
      controller.selection = TextSelection.collapsed(offset: textLength);
    });
  }

  String? _requiredCityValidator(String? value) {
    return value == null || value.trim().isEmpty ? 'يرجى اختيار المدينة' : null;
  }

  String? _requiredNeighborhoodValidator(String? value) {
    return value == null || value.trim().isEmpty ? 'يرجى اختيار الحي' : null;
  }

  String? _requiredDirectionsValidator(String? value) {
    return value == null || value.trim().isEmpty
        ? 'يرجى إدخال تفاصيل العنوان الأخرى'
        : null;
  }

  Future<void> _pickAddressFromMap() async {
    final selected = await Navigator.of(context).push<_AddressMapSelection>(
      MaterialPageRoute<_AddressMapSelection>(
        builder: (_) => _AddressMapPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );
    if (!mounted || selected == null) return;

    setState(() {
      _latitude = selected.latitude;
      _longitude = selected.longitude;
    });
  }

  bool _validateLocationBeforeSubmit() {
    if (_hasSelectedLocation) return true;
    AppToast.showToast(
      context: context,
      message: 'يرجى تحديد العنوان على الخريطة أولًا',
      type: ToastificationType.error,
    );
    return false;
  }
}

class _AddressMapPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const _AddressMapPickerScreen({
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  State<_AddressMapPickerScreen> createState() =>
      _AddressMapPickerScreenState();
}

class _AddressMapPickerScreenState extends State<_AddressMapPickerScreen> {
  static const LatLng _defaultCenter = LatLng(33.5138, 36.2765);

  LatLng? _selected;
  bool _isResolvingInitialLocation = false;

  bool get _hasInitialCoordinates =>
      widget.initialLatitude != null && widget.initialLongitude != null;

  @override
  Widget build(BuildContext context) {
    final selected = _selected;

    return Scaffold(
      appBar: AppBar(title: const Text('تحديد الموقع على الخريطة')),
      body: Column(
        children: [
          Expanded(
            child: _isResolvingInitialLocation || selected == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: selected,
                      initialZoom: 17,
                      onTap: (_, point) {
                        setState(() => _selected = point);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.dllni.user',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selected,
                            width: 44,
                            height: 44,
                            child: const Icon(
                              Icons.location_on_rounded,
                              size: 40,
                              color: Color(0xffE51C28),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (selected != null)
                  Text(
                    'Lat: ${selected.latitude.toStringAsFixed(6)}  •  Lng: ${selected.longitude.toStringAsFixed(6)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xff6B7280),
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: selected == null
                      ? null
                      : () {
                          Navigator.of(context).pop(
                            _AddressMapSelection(
                              latitude: selected.latitude,
                              longitude: selected.longitude,
                            ),
                          );
                        },
                  child: const Text('تأكيد الموقع'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (_hasInitialCoordinates) {
      _selected = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      return;
    }
    _isResolvingInitialLocation = true;
    _resolveInitialLocation();
  }

  Future<void> _resolveInitialLocation() async {
    final location = await getIt<UserLocationService>().getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _isResolvingInitialLocation = false;
      if (location.latitude != null && location.longitude != null) {
        _selected = LatLng(location.latitude!, location.longitude!);
      } else {
        _selected = _defaultCenter;
      }
    });
  }
}

class _AddressMapSelection {
  final double latitude;
  final double longitude;

  const _AddressMapSelection({required this.latitude, required this.longitude});
}

class _AddressTypeSelector extends StatelessWidget {
  static const _types = ['المنزل', 'العمل', 'العائلة'];

  final String value;
  final ValueChanged<String> onChanged;

  const _AddressTypeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyMedium('أيقونة العنوان', fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            hintText: 'اختر نوع العنوان',
            hintStyle: const TextStyle(
              color: AppColors.hintText,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xffF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xffE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xffE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.primary, width: 1.2),
            ),
          ),
          items: _types
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: AppText.bodyMedium(item),
                ),
              )
              .toList(),
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ],
    );
  }
}
