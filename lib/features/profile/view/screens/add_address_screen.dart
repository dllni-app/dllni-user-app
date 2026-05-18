import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:toastification/toastification.dart';

import '../../domain/models/address_list_item.dart';
import '../../domain/usecases/create_address_use_case.dart';
import '../../domain/usecases/update_address_use_case.dart';
import '../helpers/nominatim_reverse_geocoding.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/filled_text_field.dart';
import '../widgets/numbered_section_card.dart';
import '../widgets/personal_details_app_bar.dart';

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

class CreatedAddressSelectionHint {
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
}

@AutoRoutePage()
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key, required this.params});

  final MyAddressesScreenParams params;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _mobileController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _directionsController = TextEditingController();

  String _selectedType = 'المنزل';
  bool _isDefault = true;
  bool _isResolvingMap = false;

  double? _latitude;
  double? _longitude;

  bool get _isEditMode => widget.params.addressItem != null;
  bool get _hasSelectedLocation => _latitude != null && _longitude != null;

  @override
  void dispose() {
    _labelController.dispose();
    _mobileController.dispose();
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
    if (item == null) return;
    _labelController.text = item.label;
    _mobileController.text = item.mobile ?? '';
    _cityController.text = item.city ?? '';
    _neighborhoodController.text = item.neighborhood ?? '';
    _streetController.text = item.street ?? '';
    _buildingController.text = item.building ?? '';
    _floorController.text = item.floor ?? '';
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
      _isResolvingMap = true;
    });

    final fields = await NominatimReverseGeocoding().reverse(
      latitude: selected.latitude,
      longitude: selected.longitude,
    );
    if (!mounted) return;

    setState(() {
      _isResolvingMap = false;
      if (fields == null) return;
      if ((fields.city ?? '').isNotEmpty) {
        _cityController.text = fields.city!;
      }
      if ((fields.neighborhood ?? '').isNotEmpty) {
        _neighborhoodController.text = fields.neighborhood!;
      }
      if ((fields.street ?? '').isNotEmpty) {
        _streetController.text = fields.street!;
      }
      if ((fields.building ?? '').isNotEmpty) {
        _buildingController.text = fields.building!;
      }
      if ((fields.directions ?? '').isNotEmpty) {
        _directionsController.text = fields.directions!;
      }
    });

    if (fields == null || !fields.hasAnyData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديد الموقع، يرجى إدخال بيانات العنوان يدويًا.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديد الموقع وتعبئة البيانات المتاحة من الخريطة.'),
      ),
    );
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
      mobile: _mobileController.text.trim(),
      city: _cityController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      street: _streetController.text.trim(),
      floor: _floorController.text.trim(),
      latitude: _latitude!,
      longitude: _longitude!,
      building: _buildingController.text.trim().isEmpty
          ? null
          : _buildingController.text.trim(),
      directions: _directionsController.text.trim().isEmpty
          ? null
          : _directionsController.text.trim(),
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
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
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
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'رقم الجوال',
                            isRequired: true,
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            validator: _requiredValidator,
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
                          ],
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'اسم الحي',
                            isRequired: true,
                            controller: _neighborhoodController,
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'اسم الشارع',
                            isRequired: true,
                            controller: _streetController,
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'اسم البناء',
                            controller: _buildingController,
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'رقم الطابق',
                            isRequired: true,
                            controller: _floorController,
                            keyboardType: TextInputType.number,
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'المدينة',
                            isRequired: true,
                            controller: _cityController,
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          FilledTextField(
                            label: 'تفاصيل أخرى',
                            controller: _directionsController,
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
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 20),
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
                                : () {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    if (!_validateLocationBeforeSubmit()) {
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
                                            label: _labelController.text.trim(),
                                            mobile: _mobileController.text
                                                .trim(),
                                            city: _cityController.text.trim(),
                                            neighborhood:
                                                _neighborhoodController.text
                                                    .trim(),
                                            street: _streetController.text
                                                .trim(),
                                            building: _buildingController.text
                                                .trim(),
                                            floor: _floorController.text.trim(),
                                            directions: _directionsController
                                                .text
                                                .trim(),
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
                                          mobile: _mobileController.text.trim(),
                                          city: _cityController.text.trim(),
                                          neighborhood: _neighborhoodController
                                              .text
                                              .trim(),
                                          street: _streetController.text.trim(),
                                          building:
                                              _buildingController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _buildingController.text.trim(),
                                          floor: _floorController.text.trim(),
                                          directions:
                                              _directionsController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _directionsController.text
                                                    .trim(),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressTypeSelector extends StatelessWidget {
  const _AddressTypeSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _types = ['المنزل', 'العمل', 'العائلة'];

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

class _AddressMapSelection {
  const _AddressMapSelection({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class _AddressMapPickerScreen extends StatefulWidget {
  const _AddressMapPickerScreen({
    required this.initialLatitude,
    required this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<_AddressMapPickerScreen> createState() =>
      _AddressMapPickerScreenState();
}

class _AddressMapPickerScreenState extends State<_AddressMapPickerScreen> {
  static const LatLng _defaultCenter = LatLng(33.5138, 36.2765);
  late LatLng _selected;

  @override
  void initState() {
    super.initState();
    _selected = LatLng(
      widget.initialLatitude ?? _defaultCenter.latitude,
      widget.initialLongitude ?? _defaultCenter.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحديد الموقع على الخريطة')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _selected,
                initialZoom: 15,
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
                      point: _selected,
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
                Text(
                  'Lat: ${_selected.latitude.toStringAsFixed(6)}  •  Lng: ${_selected.longitude.toStringAsFixed(6)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xff6B7280),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _AddressMapSelection(
                        latitude: _selected.latitude,
                        longitude: _selected.longitude,
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
}
