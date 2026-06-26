import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/female_worker_safety_policy_model.dart';
import '../../domain/models/work_environment_confirmation.dart';

Future<WorkEnvironmentConfirmation?> showFemaleWorkerSafetyConfirmationSheet({
  required BuildContext context,
  required FemaleWorkerSafetyPolicyModel policy,
}) {
  return showModalBottomSheet<WorkEnvironmentConfirmation>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _FemaleWorkerSafetyConfirmationSheet(policy: policy),
  );
}

class _FemaleWorkerSafetyConfirmationSheet extends StatefulWidget {
  const _FemaleWorkerSafetyConfirmationSheet({required this.policy});

  final FemaleWorkerSafetyPolicyModel policy;

  @override
  State<_FemaleWorkerSafetyConfirmationSheet> createState() =>
      _FemaleWorkerSafetyConfirmationSheetState();
}

class _FemaleWorkerSafetyConfirmationSheetState
    extends State<_FemaleWorkerSafetyConfirmationSheet> {
  String? _selectedPresence;
  bool _pledgeAccepted = false;
  String? _errorMessage;

  FemaleWorkerSafetyOptionModel? get _selectedOption {
    final value = _selectedPresence;
    if (value == null) return null;
    return widget.policy.optionByValue(value);
  }

  void _submit() {
    final selectedOption = _selectedOption;
    if (selectedOption == null) {
      setState(() => _errorMessage = 'يرجى اختيار من سيكون متواجداً في الموقع');
      return;
    }

    if (!selectedOption.allowed) {
      setState(() {
        _errorMessage = selectedOption.blockedMessage ??
            'لا يمكن متابعة الطلب بهذا الخيار، يمكنك اختيار عامل ذكر.';
      });
      return;
    }

    if (!_pledgeAccepted) {
      setState(() => _errorMessage = 'يرجى الموافقة على التعهد قبل المتابعة');
      return;
    }

    Navigator.of(context).pop(
      WorkEnvironmentConfirmation(
        beneficiaryPresence: selectedOption.value,
        pledgeAccepted: true,
        pledgeVersion: widget.policy.pledge.version,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final allowedOption = _selectedOption?.allowed ?? false;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 20,
        end: 20,
        top: 18,
        bottom: bottomInset + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppText.titleMedium(
              widget.policy.title,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText.bodyMedium(
              widget.policy.question,
              color: const Color(0xFF4B5563),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...widget.policy.options.map(
              (option) => RadioListTile<String>(
                value: option.value,
                groupValue: _selectedPresence,
                onChanged: (value) {
                  setState(() {
                    _selectedPresence = value;
                    _errorMessage = option.allowed
                        ? null
                        : option.blockedMessage ??
                            'لا يمكن متابعة الطلب بهذا الخيار، يمكنك اختيار عامل ذكر.';
                  });
                },
                title: Text(
                  option.label,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                activeColor: const Color(0xFF1E2A78),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (allowedOption) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText.labelLarge(
                      widget.policy.pledge.title,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    AppText.bodySmall(
                      widget.policy.pledge.body,
                      color: const Color(0xFF92400E),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      value: _pledgeAccepted,
                      onChanged: (value) {
                        setState(() {
                          _pledgeAccepted = value ?? false;
                          if (_pledgeAccepted) _errorMessage = null;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        widget.policy.pledge.acceptanceLabel,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      activeColor: const Color(0xFF1E2A78),
                    ),
                  ],
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: AppText.bodySmall(
                  _errorMessage!,
                  color: const Color(0xFFB91C1C),
                  textAlign: TextAlign.right,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('متابعة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
