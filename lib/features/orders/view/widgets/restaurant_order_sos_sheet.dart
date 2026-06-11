import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/orders/data/models/sos_api_models.dart';
import 'package:dllni_user_app/features/orders/domain/usecases/sos_use_cases.dart';
import 'package:flutter/material.dart';

class RestaurantOrderSosSheet extends StatefulWidget {
  const RestaurantOrderSosSheet({super.key, required this.orderId});

  final int orderId;

  static Future<void> show(BuildContext context, {required int orderId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RestaurantOrderSosSheet(orderId: orderId),
    );
  }

  @override
  State<RestaurantOrderSosSheet> createState() => _RestaurantOrderSosSheetState();
}

class _RestaurantOrderSosSheetState extends State<RestaurantOrderSosSheet> {
  static const _options = <({String id, String label})>[
    (id: 'unsafe', label: 'أشعر بعدم الأمان / تهديد'),
    (id: 'medical', label: 'حدثت حالة طبية طارئة'),
    (id: 'dispute', label: 'هنالك خلاف حاد'),
  ];

  final Set<String> _selected = <String>{};
  bool _submitting = false;

  Future<void> _submit() async {
    if (_selected.isEmpty || _submitting) return;
    setState(() => _submitting = true);

    final Either<Failure, CreateUserSosResponseModel> result =
        await getIt<CreateUserSosUseCase>()(
          CreateUserSosParams(
            orderId: widget.orderId,
            reasons: _selected.toList(growable: false),
          ),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال تنبيه SOS بنجاح')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.titleMedium('طلب SOS', fontWeight: FontWeight.bold),
          const SizedBox(height: 8),
          AppText.bodySmall(
            'اختر سبب الطوارئ وسيتم إرسال تنبيه فوري.',
            color: const Color(0xff6B7280),
          ),
          const SizedBox(height: 16),
          ..._options.map((option) {
            final checked = _selected.contains(option.id);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: checked,
              onChanged: _submitting
                  ? null
                  : (value) {
                      setState(() {
                        if (value == true) {
                          _selected.add(option.id);
                        } else {
                          _selected.remove(option.id);
                        }
                      });
                    },
              title: AppText.bodyMedium(option.label, textAlign: TextAlign.start),
            );
          }),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _selected.isEmpty || _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : AppText.labelLarge('إرسال SOS', color: Colors.white),
          ),
        ],
      ),
    );
  }
}
