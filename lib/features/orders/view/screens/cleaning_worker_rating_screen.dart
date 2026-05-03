import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../domain/usecases/submit_cleaning_review_use_case.dart';

class CleaningWorkerRatingArgs {
  const CleaningWorkerRatingArgs({
    required this.orderId,
    this.workerId,
    this.workerName,
    this.workerAvatarUrl,
  });

  final int orderId;
  final int? workerId;
  final String? workerName;
  final String? workerAvatarUrl;
}

@AutoRoutePage(path: '/cleaning-worker-rating')
class CleaningWorkerRatingScreen extends StatefulWidget {
  const CleaningWorkerRatingScreen({super.key, required this.args});

  final CleaningWorkerRatingArgs args;

  @override
  State<CleaningWorkerRatingScreen> createState() =>
      _CleaningWorkerRatingScreenState();
}

class _CleaningWorkerRatingScreenState
    extends State<CleaningWorkerRatingScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;

  static const List<String> _quickTags = ['تأخر عن الموعد', 'عمل غير متقن'];
  final Set<String> _selectedTags = <String>{};

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || _rating < 1) return;
    setState(() => _submitting = true);
    final Either<Failure, dynamic> response =
        await getIt<SubmitCleaningReviewUseCase>()(
          SubmitCleaningReviewParams(
            orderId: widget.args.orderId,
            rating: _rating,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
            tags: _selectedTags.isEmpty ? null : _selectedTags.toList(),
          ),
        );

    if (!mounted) return;
    setState(() => _submitting = false);
    response.fold(
      (_) {
        AppToast.showToast(
          context: context,
          message: 'شكراً لتقييمك',
          type: ToastificationType.success,
        );
        Navigator.of(context).pop();
      },
      (_) {
        AppToast.showToast(
          context: context,
          message: 'تم إرسال التقييم',
          type: ToastificationType.success,
        );
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerName = widget.args.workerName ?? 'مقدم الخدمة';
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: widget.args.workerAvatarUrl == null
                ? Container(color: const Color(0xff1E2A78))
                : Image.network(
                    widget.args.workerAvatarUrl!,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withAlpha(80))),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundImage: widget.args.workerAvatarUrl == null
                              ? null
                              : NetworkImage(widget.args.workerAvatarUrl!),
                          child: widget.args.workerAvatarUrl == null
                              ? const Icon(Icons.person, size: 42)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        AppText.titleMedium(
                          workerName,
                          fontWeight: FontWeight.bold,
                        ),
                        AppText.bodySmall(
                          'عامل تنظيف',
                          color: const Color(0xff6B7280),
                        ),
                        const SizedBox(height: 16),
                        AppText.bodyMedium(
                          'كيف كانت تجربتك مع عامل التنظيفات $workerName ؟',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        AppText.bodySmall(
                          'تقييمك الكلي',
                          color: const Color(0xff9CA3AF),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(5, (index) {
                            final isSelected = _rating >= index + 1;
                            return IconButton(
                              onPressed: () =>
                                  setState(() => _rating = index + 1),
                              icon: Icon(
                                Icons.star_rounded,
                                color: isSelected
                                    ? const Color(0xffFBBF24)
                                    : const Color(0xff9CA3AF),
                                size: 34,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _quickTags.map((tag) {
                            final selected = _selectedTags.contains(tag);
                            return ChoiceChip(
                              label: Text(tag),
                              selected: selected,
                              onSelected: (value) {
                                setState(() {
                                  if (value) {
                                    _selectedTags.add(tag);
                                  } else {
                                    _selectedTags.remove(tag);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'اكتب ملاحظاتك هنا',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _submitting
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                child: AppText.labelLarge(
                                  'لا أريد التقييم، شكراً',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: (_rating < 1 || _submitting)
                                    ? null
                                    : _submit,
                                child: _submitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : AppText.labelLarge(
                                        'إرسال التقييم',
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
