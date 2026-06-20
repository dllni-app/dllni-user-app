import 'dart:convert';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/helpers/phone_number_helper.dart';
import 'package:dllni_user_app/core/session/user_session_store.dart';
import 'package:dllni_user_app/core/widgets/app_phone_number_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:latlong2/latlong.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/session/user_session_keys.dart';
import '../../../auth/data/models/login_response_model.dart';
import '../../domain/models/address_list_item.dart';
import '../../domain/services/user_location_service.dart';
import '../../domain/usecases/create_address_use_case.dart';
import '../../domain/usecases/update_address_use_case.dart';
import '../helpers/nominatim_reverse_geocoding.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/filled_text_field.dart';
import '../widgets/numbered_section_card.dart';
import '../widgets/personal_details_app_bar.dart';

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

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _phoneFieldKey = GlobalKey<AppPhoneNumberFieldState>();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _directionsController = TextEditingController();

  String _selectedType = 'المنزل';
  bool _isDefault = true;
  bool _isResolvingMap = false;

  bool _cityEdited = false;
  bool _directionsEdited = false;
  bool _neighborhoodEdited = false;
  bool _streetEdited = false;

  double? _latitude;
  double? _longitude;

  PhoneNumber? _phone;
  PhoneNumber? _initialPhone;
  bool _isLoadingPhone = false;

  bool get _hasSelectedLocation => _latitude != null && _longitude != null;
  bool get _isEditMode => widget.params.addressItem != null;

  @override
  void dispose() {
    _labelController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _directionsController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final item = widget.params.addressItem;
    if (item == null) {
     final json = SharedPreferencesHelper.getData(key: UserSessionKeys.loggedInUser);
     final user = LoggedInUserModel.fromJson(jsonDecode(json));
     _isLoadingPhone = true;
     _loadInitialPhone(user.phone);
      // final authPhone = UserSessionStore.phone();
      // if ((authPhone ?? '').trim().isNotEmpty) {
      //   _isLoadingPhone = true;
      //   _loadInitialPhone(authPhone);
      // }
      return;
    }
    _isLoadingPhone = true;
    _labelController.text = item.label;
    _loadInitialPhone(item.mobile);
    _cityController.text = item.city ?? '';
    _neighborhoodController.text = item.neighborhood ?? '';
    _streetController.text = item.street ?? '';
    _buildingController.text = item.building ?? '';
    _floorController.text = item.floor ?? '';
    _isDefault = item.isDefault;
    _latitude = item.latitude;
    _longitude = item.longitude;
    _selectedType = switch (item.type) {
      AddressType.work => 'العمل',
      AddressType.family => 'العائلة',
      AddressType.home => 'المنزل',
    };
  }

  Future<void> _loadInitialPhone(String? mobile) async {
    final parsed = await parseInitialPhone(mobile);
    if (!mounted) return;
    setState(() {
      _initialPhone = parsed;
      _phone = parsed;
      _isLoadingPhone = false;
    });
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

    await _reverseGeocodeSelectedLocation();
  }

  Future<void> _reverseGeocodeSelectedLocation({bool forceFill = false}) async {
    if (_latitude == null || _longitude == null) return;

    setState(() => _isResolvingMap = true);

    final fields = await NominatimReverseGeocoding().reverse(
      latitude: _latitude!,
      longitude: _longitude!,
      acceptLanguage: "ar",
    );
    if (!mounted) return;

    setState(() {
      _isResolvingMap = false;
      if (fields == null) return;

      _autofillTextField(
        controller: _cityController,
        value: fields.city,
        wasEdited: _cityEdited,
        forceFill: forceFill,
      );
      _autofillTextField(
        controller: _neighborhoodController,
        value: fields.neighborhood,
        wasEdited: _neighborhoodEdited,
        forceFill: forceFill,
      );
      _autofillTextField(
        controller: _streetController,
        value: fields.street,
        wasEdited: _streetEdited,
        forceFill: forceFill,
      );
    });

    _showReverseGeocodingMessage(fields);
  }

  void _autofillTextField({
    required TextEditingController controller,
    required String? value,
    required bool wasEdited,
    required bool forceFill,
  }) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return;

    final shouldFill =
        forceFill || !wasEdited || controller.text.trim().isEmpty;
    if (shouldFill) {
      _setTextFieldValueAtEnd(controller, normalized);
    }
  }

  void _setTextFieldValueAtEnd(TextEditingController controller, String value) {
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _moveCursorToTextEnd(TextEditingController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final textLength = controller.text.length;
      controller.selection = TextSelection.collapsed(offset: textLength);
    });
  }

  void _showReverseGeocodingMessage(NominatimAddressFields? fields) {
    if (!mounted) return;

    final message = fields == null || !fields.hasAnyData
        ? 'تم تحديد الموقع، لكن لم نتمكن من جلب تفاصيل العنوان. يرجى إدخال البيانات يدويًا.'
        : (fields.street ?? '').trim().isEmpty ||
              (fields.neighborhood ?? '').trim().isEmpty
        ? 'تم تعبئة بيانات العنوان الأساسية من الخريطة. يرجى إكمال الحقول الناقصة يدويًا.'
        : 'تم تعبئة المدينة والحي والشارع من الخريطة، ويمكنك تعديلها قبل الحفظ.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

  CreatedAddressSelectionHint _buildCreatedAddressHint() {
    return CreatedAddressSelectionHint(
      label: _labelController.text.trim(),
      mobile: formatPhoneForApi(_phone) ?? '',
      city: _cityController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      street: _streetController.text.trim(),
      floor: _floorController.text.trim(),
      latitude: _latitude!,
      longitude: _longitude!,
      building: _buildingController.text.trim().isEmpty
          ? null
          : _buildingController.text.trim(),
    );
  }

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
                          FilledTextField(
                            label: 'اسم العنوان',
                            isRequired: true,
                            controller: _labelController,
                            validator: _requiredValidator,
                            onTap: () => _moveCursorToTextEnd(_labelController),
                          ),
                          const SizedBox(height: 12),
                          if (_isLoadingPhone)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else
                            AppPhoneNumberField(
                              key: _phoneFieldKey,
                              label: 'رقم الجوال',
                              isRequired: true,
                              initialValue: _initialPhone,
                              variant: AppPhoneFieldVariant.profile,
                              onChanged: (phone) => _phone = phone,
                            ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isResolvingMap
                                ? null
                                : _pickAddressFromMap,
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
                          if (_isResolvingMap) ...[
                            const SizedBox(height: 8),
                            const LinearProgressIndicator(minHeight: 2),
                          ],
                          if (_hasSelectedLocation) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Lat: ${_latitude!.toStringAsFixed(6)}  •  Lng: ${_longitude!.toStringAsFixed(6)}',
                              style: const TextStyle(
                                color: Color(0xff6B7280),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton.icon(
                              onPressed: _isResolvingMap
                                  ? null
                                  : () => _reverseGeocodeSelectedLocation(
                                      forceFill: true,
                                    ),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text(
                                'تحديث بيانات العنوان من الخريطة',
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'اسم الحي',
                            isRequired: true,
                            controller: _neighborhoodController,
                            validator: _requiredValidator,
                            onTap: () =>
                                _moveCursorToTextEnd(_neighborhoodController),
                            onChanged: (_) => _neighborhoodEdited = true,
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'اسم الشارع',
                            isRequired: true,
                            controller: _streetController,
                            validator: _requiredValidator,
                            onTap: () =>
                                _moveCursorToTextEnd(_streetController),
                            onChanged: (_) => _streetEdited = true,
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'اسم البناء',
                            controller: _buildingController,
                            onTap: () =>
                                _moveCursorToTextEnd(_buildingController),
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'رقم الطابق',
                            controller: _floorController,
                            keyboardType: TextInputType.number,
                            validator: _requiredValidator,
                            onTap: () => _moveCursorToTextEnd(_floorController),
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'المدينة',
                            isRequired: true,
                            controller: _cityController,
                            validator: _requiredValidator,
                            onTap: () => _moveCursorToTextEnd(_cityController),
                            onChanged: (_) => _cityEdited = true,
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'تفاصيل أخرى',
                            controller: _directionsController,
                            onTap: () =>
                                _moveCursorToTextEnd(_directionsController),
                            onChanged: (_) => _directionsEdited = true,
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
                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      if (!_validateLocationBeforeSubmit()) {
                                        return;
                                      }

                                      final phoneError = await _phoneFieldKey
                                          .currentState
                                          ?.validate();
                                      if (!context.mounted) return;
                                      if (phoneError != null) {
                                        AppToast.showToast(
                                          context: context,
                                          message: phoneError,
                                          type: ToastificationType.error,
                                        );
                                        return;
                                      }

                                      final mobile = formatPhoneForApi(_phone);
                                      if (mobile == null) {
                                        AppToast.showToast(
                                          context: context,
                                          message: 'يرجى إدخال رقم الجوال',
                                          type: ToastificationType.error,
                                        );
                                        return;
                                      }

                                      if (_isEditMode) {
                                        final addressId = int.tryParse(
                                          widget.params.addressItem!.id,
                                        );
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
                                              label: _labelController.text
                                                  .trim(),
                                              mobile: mobile,
                                              city: _cityController.text.trim(),
                                              neighborhood:
                                                  _neighborhoodController.text
                                                      .trim(),
                                              street: _streetController.text
                                                  .trim(),
                                              building: _buildingController.text
                                                  .trim(),
                                              floor: _floorController.text
                                                  .trim(),
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
                                            label: _labelController.text.trim(),
                                            mobile: mobile,
                                            city: _cityController.text.trim(),
                                            neighborhood:
                                                _neighborhoodController.text
                                                    .trim(),
                                            street: _streetController.text
                                                .trim(),
                                            building:
                                                _buildingController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _buildingController.text
                                                      .trim(),
                                            floor: _floorController.text.trim(),
                                            directions: _directionsController.text.trim(),
                                            isDefault: _isDefault,
                                            latitude: _latitude!,
                                            longitude: _longitude!,
                                          ),
                                        ),
                                      );
                                    },
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
                                _isEditMode ? 'حفظ التعديلات' : 'أضف العنوان',
                                color: context.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => context.pop(false),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: context.error),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: AppText.labelLarge(
                                'إلغاء',
                                color: context.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
