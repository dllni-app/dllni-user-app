class WorkEnvironmentConfirmation {
  final String beneficiaryPresence;
  final bool pledgeAccepted;
  final String pledgeVersion;

  const WorkEnvironmentConfirmation({
    required this.beneficiaryPresence,
    required this.pledgeAccepted,
    required this.pledgeVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'beneficiaryPresence': beneficiaryPresence,
      'pledgeAccepted': pledgeAccepted,
      'pledgeVersion': pledgeVersion,
    };
  }
}

class WorkEnvironmentBeneficiaryPresence {
  static const String femalePresent = 'female_present';
  static const String blockedPresence = 'male' '_alone';

  const WorkEnvironmentBeneficiaryPresence._();
}
