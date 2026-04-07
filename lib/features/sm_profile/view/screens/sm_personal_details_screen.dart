import 'dart:developer';
import 'dart:io';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/widgets/app_app_bars.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/step_details.dart';
import '../widgets/sm_change_password_section.dart';
import '../widgets/sm_account_info_section.dart';
import '../widgets/sm_profile_photo_section.dart';

class SmPersonalDetailsParams {
  const SmPersonalDetailsParams({
    required this.name,
    this.phoneLocal,
    this.dialCode = '+963',
    this.isPhoneVerified = true,
    this.avatarUrl,
    this.email,
  });

  final String name;
  final String? phoneLocal;
  final String dialCode;
  final bool isPhoneVerified;
  final String? avatarUrl;
  final String? email;
}

@AutoRoutePage(path: "/sm_personal_details")
class SmPersonalDetailsScreen extends StatefulWidget {
  const SmPersonalDetailsScreen({super.key, required this.params});

  final SmPersonalDetailsParams params;

  @override
  State<SmPersonalDetailsScreen> createState() =>
      _SmPersonalDetailsScreenState();
}

class _SmPersonalDetailsScreenState extends State<SmPersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneLocalController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  String _dialCode = '+963';
  static const List<String> _dialCodes = [
    '+963',
    '+966',
    '+971',
    '+962',
    '+20',
  ];

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
    _phoneLocalController = TextEditingController(
      text: widget.params.phoneLocal ?? '',
    );
    _dialCode = widget.params.dialCode;
    if (!_dialCodes.contains(_dialCode)) {
      _dialCode = _dialCodes.first;
    }
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneLocalController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryContainer;

    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      body: Column(
        children: [
          AppSimpleAppBar(title: "التفاصيل الشخصية"),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StepDetails(
                      number: 1,
                      title: 'الصورة الشخصية',
                      child: SmProfilePhotoSection(
                        accentColor: accent,
                        localFile: _selectedImage,
                        networkImageUrl: widget.params.avatarUrl,
                        onPickGallery: () => _pickImage(ImageSource.gallery),
                        onPickCamera: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(height: 16),
                    StepDetails(
                      number: 2,
                      title: 'معلومات الحساب',
                      child: SmAccountInfoSection(
                        nameController: _nameController,
                        phoneLocalController: _phoneLocalController,
                        dialCode: _dialCode,
                        dialCodes: _dialCodes,
                        isPhoneVerified: widget.params.isPhoneVerified,
                        onDialCodeChanged: (v) {
                          if (v != null) setState(() => _dialCode = v);
                        },
                        nameValidator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'الرجاء إدخال الاسم';
                          }
                          return null;
                        },
                        phoneValidator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    StepDetails(
                      number: 3,
                      title: 'تغيير كلمة المرور',
                      child: SmChangePasswordSection(
                        currentController: _currentPasswordController,
                        newController: _newPasswordController,
                        confirmController: _confirmPasswordController,
                        obscureCurrent: _obscureCurrent,
                        obscureNew: _obscureNew,
                        obscureConfirm: _obscureConfirm,
                        passwordMismatch: _passwordMismatch,
                        onToggleCurrent: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                        onToggleNew: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        onToggleConfirm: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        onPasswordChanged: _syncPasswordMismatch,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: AppButton(
                            title: "حفظ التغييرات",
                            onTap: () {},
                          ),
                        ),
                        AppOutlinedButton(
                          color: Color(0xFFFF4C51),
                          title: "إلغاء",
                          onTap: () {},
                        ),
                      ],
                    ),
                    // RsPersonalDetailsFooter(
                    //   isSaving: isSaving,
                    //   onSave: () {
                    //     _syncPasswordMismatch();
                    //     if (!_formKey.currentState!.validate()) return;
                    //     if (!_validatePasswordSection()) return;
                    //   },
                    //   onCancel: () => context.pop(),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
