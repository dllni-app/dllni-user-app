import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

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
  State<CleaningOrderProblemReportScreen> createState() => _CleaningOrderProblemReportScreenState();
}

class _CleaningOrderProblemReportScreenState extends State<CleaningOrderProblemReportScreen> {
  static const int _descriptionLimit = 200;
  final TextEditingController _descriptionController = TextEditingController();
  int? _selectedIssueIndex;

  final List<({String title, String subtitle})> _issues = const <({String title, String subtitle})>[
    (title: 'جودة الخدمة لم تكن مرضية', subtitle: 'لم أرَ كما كنت أتوقع'),
    (title: 'حدث ضرر لأحد الممتلكات', subtitle: 'إهمال التعامل بالممتلكات'),
    (title: 'سلوك مقدم الخدمة كان غير لائق', subtitle: 'تحدث بأسلوب غير لائق'),
    (title: 'مشكلة في الفاتورة', subtitle: 'المبلغ النهائي غير كما هو في تفاصيل الحجز'),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final description = _descriptionController.text.trim();
    if (_selectedIssueIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تحديد طبيعة المشكلة')));
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة وصف المشكلة')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال المشكلة بنجاح')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final descriptionLength = _descriptionController.text.length;
    final booking = widget.args.order.bookingNumber ?? '#${widget.args.order.id ?? '-'}';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF4F5F7),
        appBar: AppBar(
          backgroundColor: const Color(0xffF4F5F7),
          elevation: 0,
          centerTitle: true,
          title: const Text('وصف المشكلة', style: TextStyle(color: Color(0xff1F2937), fontWeight: FontWeight.w700)),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffE5E7EB)),
                        ),
                        child: Text(
                          'رقم الطلب: $booking',
                          style: const TextStyle(color: Color(0xff6B7280), fontWeight: FontWeight.w600, fontSize: 12),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                CircleAvatar(radius: 11, backgroundColor: Color(0xff20BFC8), child: Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11))),
                                SizedBox(width: 8),
                                Text('تحديد طبيعة المشكلة', style: TextStyle(color: Color(0xff1F2937), fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Padding(
                              padding: EdgeInsetsDirectional.only(start: 30),
                              child: Text('اختر نوع مشكلتك لمساعدتك', style: TextStyle(color: Color(0xff9CA3AF), fontSize: 12)),
                            ),
                            const SizedBox(height: 10),
                            ...List.generate(_issues.length, (index) {
                              final item = _issues[index];
                              final selected = _selectedIssueIndex == index;
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(bottom: 8),
                                child: InkWell(
                                  onTap: () => setState(() => _selectedIssueIndex = index),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: selected ? const Color(0xffEEF6FF) : const Color(0xffF9FAFB),
                                      border: Border.all(color: selected ? const Color(0xff20BFC8) : const Color(0xffE5E7EB)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.title, style: const TextStyle(color: Color(0xff1F2937), fontWeight: FontWeight.w600, fontSize: 13)),
                                              const SizedBox(height: 2),
                                              Text(item.subtitle, style: const TextStyle(color: Color(0xff9CA3AF), fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                        Checkbox(
                                          value: selected,
                                          activeColor: const Color(0xff20BFC8),
                                          onChanged: (_) => setState(() => _selectedIssueIndex = index),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                CircleAvatar(radius: 11, backgroundColor: Color(0xff20BFC8), child: Text('2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11))),
                                SizedBox(width: 8),
                                Text('تقديم وصف تفصيلي للمشكلة', style: TextStyle(color: Color(0xff1F2937), fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Padding(
                              padding: EdgeInsetsDirectional.only(start: 30),
                              child: Text('هل لديك ملاحظات أو تفاصيل تدعم شكواك؟', style: TextStyle(color: Color(0xff9CA3AF), fontSize: 12)),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 5,
                              maxLength: _descriptionLimit,
                              decoration: InputDecoration(
                                hintText: 'وصف المشكلة',
                                counterText: '$descriptionLength/$_descriptionLimit',
                                filled: true,
                                fillColor: const Color(0xffF9FAFB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xff20BFC8)),
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                CircleAvatar(radius: 11, backgroundColor: Color(0xff20BFC8), child: Text('3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11))),
                                SizedBox(width: 8),
                                Text('صور الأضرار', style: TextStyle(color: Color(0xff1F2937), fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Padding(
                              padding: EdgeInsetsDirectional.only(start: 30),
                              child: Text('يرجى تقديم وصف تفصيلي للمشكلة', style: TextStyle(color: Color(0xff9CA3AF), fontSize: 12)),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF9FAFB),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xffD1D5DB), style: BorderStyle.solid),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.upload_rounded, color: Color(0xff6B7280)),
                                        SizedBox(height: 6),
                                        Text('اضغط لرفع صورة', style: TextStyle(color: Color(0xff6B7280), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    height: 90,
                                    decoration: BoxDecoration(color: const Color(0xffD1D5DB), borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('الحد الأقصى: 2 ميجابايت', style: TextStyle(color: Color(0xff6B7280), fontSize: 11)),
                            const SizedBox(height: 3),
                            const Text('الصيغ المدعومة: JPG, PNG', style: TextStyle(color: Color(0xff6B7280), fontSize: 11)),
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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xff20BFC8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('إرسال المشكلة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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
