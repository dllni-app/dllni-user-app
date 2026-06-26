class FemaleWorkerSafetyPolicyModel {
  final String title;
  final String question;
  final List<FemaleWorkerSafetyOptionModel> options;
  final FemaleWorkerSafetyPledgeModel pledge;

  const FemaleWorkerSafetyPolicyModel({
    required this.title,
    required this.question,
    required this.options,
    required this.pledge,
  });

  factory FemaleWorkerSafetyPolicyModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return FemaleWorkerSafetyPolicyModel(
      title: (data['title'] as String?)?.trim().isNotEmpty == true
          ? data['title'] as String
          : 'تأكيد بيئة العمل',
      question: (data['question'] as String?)?.trim().isNotEmpty == true
          ? data['question'] as String
          : 'من سيكون متواجداً في الموقع أثناء تقديم الخدمة؟',
      options: (data['options'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(FemaleWorkerSafetyOptionModel.fromJson)
          .toList(growable: false),
      pledge: FemaleWorkerSafetyPledgeModel.fromJson(
        data['pledge'] is Map<String, dynamic>
            ? data['pledge'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
    );
  }

  FemaleWorkerSafetyOptionModel? optionByValue(String value) {
    for (final option in options) {
      if (option.value == value) return option;
    }
    return null;
  }
}

class FemaleWorkerSafetyOptionModel {
  final String value;
  final String label;
  final bool allowed;
  final String? blockedMessage;

  const FemaleWorkerSafetyOptionModel({
    required this.value,
    required this.label,
    required this.allowed,
    this.blockedMessage,
  });

  factory FemaleWorkerSafetyOptionModel.fromJson(Map<String, dynamic> json) {
    return FemaleWorkerSafetyOptionModel(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
      allowed: json['allowed'] as bool? ?? false,
      blockedMessage: json['blockedMessage'] as String?,
    );
  }
}

class FemaleWorkerSafetyPledgeModel {
  final String version;
  final String title;
  final String body;
  final String acceptanceLabel;

  const FemaleWorkerSafetyPledgeModel({
    required this.version,
    required this.title,
    required this.body,
    required this.acceptanceLabel,
  });

  factory FemaleWorkerSafetyPledgeModel.fromJson(Map<String, dynamic> json) {
    return FemaleWorkerSafetyPledgeModel(
      version: json['version'] as String? ?? 'female-worker-safety-v1',
      title: json['title'] as String? ?? 'شروط السلامة والمسؤولية القانونية',
      body: json['body'] as String? ?? '',
      acceptanceLabel:
          json['acceptanceLabel'] as String? ?? 'أوافق على التعهد وأتحمل المسؤولية',
    );
  }
}

FemaleWorkerSafetyPolicyModel femaleWorkerSafetyPolicyModelFromJson(
  Map<String, dynamic> json,
) {
  return FemaleWorkerSafetyPolicyModel.fromJson(json);
}
