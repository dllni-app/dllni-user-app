import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/orders/domain/repository/orders_repo.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/sos_use_cases.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/cleaning_orders_api_models.dart';

class CleaningOrderProblemReportArgs {
  const CleaningOrderProblemReportArgs({required this.order});

  final CleaningOrderModel order;
}

@AutoRoutePage(path: '/cleaning-order-problem')
class CleaningOrderProblemReportScreen extends StatefulWidget {
  const CleaningOrderProblemReportScreen({super.key, required this.args});

  final CleaningOrderProblemReportArgs args;

  @override
  State<CleaningOrderProblemReportScreen> createState() =>
      _CleaningOrderProblemReportScreenState();
}

class _CleaningOrderProblemReportScreenState
    extends State<CleaningOrderProblemReportScreen> {
  static const int _descriptionLimit = 1000;
  static const int _maxAttachments = 4;

  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<({XFile file, Uint8List bytes})> _attachments = [];

  int? _selectedIssueIndex;
  bool _submitting = false;

  final List<({String category, String title, String subtitle})> _issues = const [
    (
      category: 'poor_quality',
      title: 'جودة الخدمة لم تكن مرضية',
      subtitle: 'لم تكن النتيجة كما كنت أتوقع',
    ),
    (
      category: 'property_damage',
      title: 'حدث ضرر لأحد الممتلكات',
      subtitle: 'ضرر أو إهمال في التعامل مع الممتلكات',
    ),
    (
      category: 'unprofessional',
      title: 'سلوك مقدم الخدمة كان غير لائق',
      subtitle: 'تصرف أو تحدث بأسلوب غير مناسب',
    ),
    (
      category: 'billing_issue',
      title: 'مشكلة في الفاتورة',
      subtitle: 'المبلغ لا يطابق تفاصيل الحجز',
    ),
    (
      category: 'other',
      title: 'مشكلة أخرى',
      subtitle: 'أي مشكلة أخرى مرتبطة بالخدمة',
    ),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_attachments.length >= _maxAttachments || _submitting) return;

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    if (bytes.lengthInBytes > 2 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب ألا يتجاوز حجم الصورة 2 ميجابايت')),
      );
      return;
    }

    setState(() => _attachments.add((file: picked, bytes: bytes)));
  }

  Future<void> _submit() async {
    final orderId = widget.args.order.id;
    final description = _descriptionController.text.trim();

    if (_selectedIssueIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد طبيعة المشكلة')),
      );
      return;
    }
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحديد رقم الحجز')),
      );
      return;
    }
    if (description.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة وصف واضح للمشكلة')),
      );
      return;
    }
    if (_submitting) return;

    setState(() => _submitting = true);

    final selectedIssue = _issues[_selectedIssueIndex!];
    final useCase = CreateCleaningComplaintUseCase(
      ordersRepo: getIt<OrdersRepo>(),
    );
    final result = await useCase(
      CreateCleaningComplaintParams(
        orderId: orderId,
        category: selectedIssue.category,
        description: description,
        attachmentPaths: _attachments.map((item) => item.file.path).toList(),
        clientRequestId:
            'complaint-$orderId-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (supportCase) {
        setState(() => _submitting = false);
        final caseLabel = supportCase.id == null
            ? ''
            : ' رقم البلاغ: ${supportCase.id}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال الشكوى بنجاح.$caseLabel')),
        );
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final descriptionLength = _descriptionController.text.length;
    final booking =
        widget.args.order.bookingNumber ?? '#${widget.args.order.id ?? '-'}';

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF4F5F7),
        appBar: AppBar(
          backgroundColor: const Color(0xffF4F5F7),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'الإبلاغ عن مشكلة',
            style: TextStyle(
              color: Color(0xff1F2937),
              fontWeight: FontWeight.w700,
            ),
          ),
          foregroundColor: const Color(0xff1F2937),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 24),
                  child: Column(
                    children: [
                      _card(
                        child: Text(
                          'رقم الحجز: $booking',
                          style: const TextStyle(
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _StepTitle(
                              number: '1',
                              title: 'تحديد طبيعة المشكلة',
                              subtitle: 'اختر النوع الأقرب للمشكلة التي واجهتها',
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(_issues.length, (index) {
                              final item = _issues[index];
                              final selected = _selectedIssueIndex == index;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: _submitting
                                      ? null
                                      : () => setState(
                                            () => _selectedIssueIndex = index,
                                          ),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: selected
                                          ? const Color(0xffEEF6FF)
                                          : const Color(0xffF9FAFB),
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xff20BFC8)
                                            : const Color(0xffE5E7EB),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: const TextStyle(
                                                  color: Color(0xff1F2937),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.subtitle,
                                                style: const TextStyle(
                                                  color: Color(0xff9CA3AF),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Checkbox(
                                          value: selected,
                                          activeColor: const Color(0xff20BFC8),
                                          onChanged: _submitting
                                              ? null
                                              : (_) => setState(
                                                    () =>
                                                        _selectedIssueIndex =
                                                            index,
                                                  ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _StepTitle(
                              number: '2',
                              title: 'وصف المشكلة',
                              subtitle:
                                  'أضف التفاصيل التي تساعد فريق الدعم على المراجعة',
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _descriptionController,
                              enabled: !_submitting,
                              maxLines: 5,
                              maxLength: _descriptionLimit,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'اكتب تفاصيل المشكلة',
                                counterText:
                                    '$descriptionLength/$_descriptionLimit',
                                filled: true,
                                fillColor: const Color(0xffF9FAFB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xffE5E7EB),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _StepTitle(
                              number: '3',
                              title: 'الصور والأدلة',
                              subtitle:
                                  'يمكنك إرفاق حتى 4 صور، بحد أقصى 2 ميجابايت للصورة',
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                ..._attachments.asMap().entries.map(
                                  (entry) => Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(
                                          entry.value.bytes,
                                          width: 105,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      PositionedDirectional(
                                        top: -8,
                                        end: -8,
                                        child: IconButton.filled(
                                          visualDensity: VisualDensity.compact,
                                          iconSize: 16,
                                          onPressed: _submitting
                                              ? null
                                              : () => setState(
                                                    () => _attachments.removeAt(
                                                      entry.key,
                                                    ),
                                                  ),
                                          icon: const Icon(Icons.close),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_attachments.length < _maxAttachments)
                                  InkWell(
                                    onTap: _submitting ? null : _pickImage,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 105,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffF9FAFB),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xffD1D5DB),
                                        ),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: Color(0xff6B7280),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'إضافة صورة',
                                            style: TextStyle(
                                              color: Color(0xff6B7280),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xff20BFC8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'إرسال البلاغ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: child,
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final String number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: const Color(0xff20BFC8),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xff1F2937),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xff9CA3AF),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
