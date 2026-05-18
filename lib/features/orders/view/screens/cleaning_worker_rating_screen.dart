import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../data/models/cleaning_worker_profile_model.dart';
import '../../domain/usecases/submit_cleaning_review_use_case.dart';

class CleaningWorkerRatingArgs {
  const CleaningWorkerRatingArgs({
    required this.orderId,
    required this.workerProfile,
  });

  final int orderId;
  final CleaningWorkerProfileModel workerProfile;
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

  static const List<String> _quickTags = <String>[
    'تأخر عن الموعد',
    'عمل غير متقن',
  ];
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
      (failure) {
        AppToast.showToast(
          context: context,
          message: failure.message,
          type: ToastificationType.error,
        );
      },
      (_) {
        AppToast.showToast(
          context: context,
          message: 'تم إرسال التقييم بنجاح',
          type: ToastificationType.success,
        );
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerName =
        widget.args.workerProfile.user?.name?.trim().isNotEmpty == true
        ? widget.args.workerProfile.user!.name!.trim()
        : (widget.args.workerProfile.firstName?.trim().isNotEmpty == true
              ? widget.args.workerProfile.firstName!.trim()
              : 'مقدم الخدمة');
    final workerAvatarUrl = widget.args.workerProfile.avatar?.url;
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: workerAvatarUrl == null
                        ? Container(color: const Color(0xff1E3A8A))
                        : Image.network(workerAvatarUrl, fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: Container(color: Colors.black.withAlpha(70)),
                  ),
                  Positioned.fill(
                    top: 120,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.fromLTRB(14, 56, 14, 14),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          AppText.titleLarge(
                            workerName,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 4),
                          AppText.bodyMedium(
                            'عامل تنظيف',
                            color: const Color(0xff9CA3AF),
                          ),
                          const SizedBox(height: 14),
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
                                onPressed: () {
                                  setState(() => _rating = index + 1);
                                },
                                icon: Icon(
                                  Icons.star_rounded,
                                  size: 36,
                                  color: isSelected
                                      ? const Color(0xffFBBF24)
                                      : const Color(0xffB8C0CC),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          AppText.bodyMedium(
                            'هل هناك ملاحظات تود أن تخبرنا بها ؟',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _commentController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'اكتب ملاحظاتك هنا',
                              filled: true,
                              fillColor: const Color(0xffF9FAFB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xffD1D5DB),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
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
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _submitting
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xff9CA3AF),
                                    side: const BorderSide(
                                      color: Color(0xffD1D5DB),
                                    ),
                                  ),
                                  child: AppText.labelLarge(
                                    'لا أريد التقييم، شكرا',
                                    color: const Color(0xff9CA3AF),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: (_rating < 1 || _submitting)
                                      ? null
                                      : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xff1DBCC8),
                                    foregroundColor: Colors.white,
                                  ),
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
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: workerAvatarUrl == null
                              ? null
                              : NetworkImage(workerAvatarUrl),
                          child: workerAvatarUrl == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
