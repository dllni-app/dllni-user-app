import 'dart:developer';
import 'dart:io';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/helpers/phone_number_helper.dart';
import 'package:dllni_user_app/core/widgets/app_phone_number_field.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/update_account_password_use_case.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/update_account_use_case.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:toastification/toastification.dart';

import '../widgets/account_info_section.dart';
import '../widgets/change_password_section.dart';
import '../widgets/numbered_section_card.dart';
import '../widgets/personal_details_app_bar.dart';
import '../widgets/personal_details_footer.dart';
import '../widgets/profile_photo_section.dart';

class PersonalDetailsParams {
  const PersonalDetailsParams({
    required this.name,
    this.phone,
    this.isPhoneVerified = true,
    this.avatarUrl,
    this.email,
  });

  final String name;
  final String? phone;
  final bool isPhoneVerified;
  final String? avatarUrl;
  final String? email;
}

@AutoRoutePage()
class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key, required this.params});

  final PersonalDetailsParams params;

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  final _phoneFieldKey = GlobalKey<AppPhoneNumberFieldState>();
  PhoneNumber? _phone;
  PhoneNumber? _initialPhone;
  bool _isLoadingPhone = true;

  File? _selectedImage;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _passwordMismatch = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.params.name);
    _emailController = TextEditingController(text: widget.params.email ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _loadInitialPhone();
  }

  Future<void> _loadInitialPhone() async {
    final parsed = await parseInitialPhone(widget.params.phone);
    if (!mounted) return;
    setState(() {
      _initialPhone = parsed;
      _phone = parsed;
      _isLoadingPhone = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateOptionalEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegex.hasMatch(v)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  void _syncPasswordMismatch() {
    final n = _newPasswordController.text;
    final c = _confirmPasswordController.text;
    final show = n.isNotEmpty && c.isNotEmpty && n != c;
    if (show != _passwordMismatch) {
      setState(() => _passwordMismatch = show);
    }
  }

  bool _validatePasswordSection() {
    final cur = _currentPasswordController.text;
    final n = _newPasswordController.text;
    final c = _confirmPasswordController.text;
    final any = cur.isNotEmpty || n.isNotEmpty || c.isNotEmpty;
    if (!any) return true;
    if (cur.isEmpty || n.isEmpty || c.isEmpty) {
      AppToast.showToast(
        context: context,
        message: 'يرجى إكمال حقول كلمة المرور',
        type: ToastificationType.error,
      );
      return false;
    }
    if (n != c) {
      setState(() => _passwordMismatch = true);
      return false;
    }
    return true;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(source: source);
      if (file != null) {
        setState(() => _selectedImage = File(file.path));
      }
    } catch (e) {
      log('pickImage error', error: e);
    }
  }

  bool get _hasPasswordChangeRequest {
    return _currentPasswordController.text.trim().isNotEmpty ||
        _newPasswordController.text.trim().isNotEmpty ||
        _confirmPasswordController.text.trim().isNotEmpty;
  }

  Future<void> _saveChanges() async {
    _syncPasswordMismatch();
    if (!_formKey.currentState!.validate()) return;
    if (!_validatePasswordSection()) return;

    final phoneError = await _phoneFieldKey.currentState?.validate();
    if (!mounted) return;
    if (phoneError != null) {
      AppToast.showToast(
        context: context,
        message: phoneError,
        type: ToastificationType.error,
      );
      return;
    }

    final phone = formatPhoneForApi(_phone);
    if (phone == null) {
      if (!mounted) return;
      AppToast.showToast(
        context: context,
        message: 'الرجاء إدخال رقم الهاتف',
        type: ToastificationType.error,
      );
      return;
    }

    setState(() => isSaving = true);

    String? failureMessage;
    String? successMessage;

    final accountRes = await getIt<UpdateAccountUseCase>()(
      UpdateAccountParams(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: phone,
        primaryImage: _selectedImage,
      ),
    );

    await accountRes.fold(
      (failure) async {
        failureMessage = failure.message;
      },
      (account) async {
        successMessage = account.user?.name == null
            ? 'تم تحديث البيانات الشخصية بنجاح'
            : 'تم تحديث بيانات ${account.user!.name} بنجاح';
      },
    );

    if (failureMessage == null && _hasPasswordChangeRequest) {
      final passRes = await getIt<UpdateAccountPasswordUseCase>()(
        UpdateAccountPasswordParams(
          currentPassword: _currentPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
          newPasswordConfirmation: _confirmPasswordController.text.trim(),
        ),
      );
      await passRes.fold(
        (failure) async {
          failureMessage = failure.message;
        },
        (result) async {
          successMessage = result.message ?? 'تم تحديث كلمة المرور بنجاح';
        },
      );
    }

    if (!mounted) return;
    setState(() => isSaving = false);

    if (failureMessage != null && failureMessage!.isNotEmpty) {
      AppToast.showToast(
        context: context,
        message: failureMessage!,
        type: ToastificationType.error,
      );
      return;
    }

    AppToast.showToast(
      context: context,
      message: successMessage ?? 'تم حفظ التغييرات بنجاح',
      type: ToastificationType.success,
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryContainer;

    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            const PersonalDetailsAppBar(title: 'التفاصيل الشخصية'),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NumberedSectionCard(
                        sectionNumber: '1',
                        title: 'الصورة الشخصية',
                        child: ProfilePhotoSection(
                          accentColor: accent,
                          localFile: _selectedImage,
                          networkImageUrl: widget.params.avatarUrl,
                          onPickGallery: () => _pickImage(ImageSource.gallery),
                          onPickCamera: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(height: 16),
                      NumberedSectionCard(
                        sectionNumber: '2',
                        title: 'معلومات الحساب',
                        child: _isLoadingPhone
                            ? const Center(child: CircularProgressIndicator())
                            : AccountInfoSection(
                                nameController: _nameController,
                                emailController: _emailController,
                                phoneFieldKey: _phoneFieldKey,
                                initialPhone: _initialPhone,
                                isPhoneVerified: widget.params.isPhoneVerified,
                                onPhoneChanged: (phone) => _phone = phone,
                                emailValidator: _validateOptionalEmail,
                                nameValidator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'الرجاء إدخال الاسم';
                                  }
                                  return null;
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                      NumberedSectionCard(
                        sectionNumber: '3',
                        title: 'تغيير كلمة المرور',
                        child: ChangePasswordSection(
                          currentController: _currentPasswordController,
                          newController: _newPasswordController,
                          confirmController: _confirmPasswordController,
                          obscureCurrent: _obscureCurrent,
                          obscureNew: _obscureNew,
                          obscureConfirm: _obscureConfirm,
                          passwordMismatch: _passwordMismatch,
                          onToggleCurrent: () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                          onToggleNew: () =>
                              setState(() => _obscureNew = !_obscureNew),
                          onToggleConfirm: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          onPasswordChanged: _syncPasswordMismatch,
                        ),
                      ),
                      const SizedBox(height: 32),
                      PersonalDetailsFooter(
                        isSaving: isSaving,
                        onSave: _saveChanges,
                        onCancel: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
