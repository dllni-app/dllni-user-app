import '../../data/models/luck_box_api_models.dart';

class LuckyBoxSuggestionsArgs {
  const LuckyBoxSuggestionsArgs({
    required this.groupSize,
    required this.budgetPerPerson,
    required this.restrictionValues,
    required this.cuisineTypeId,
    required this.initialResponse,
    required this.budgetSummaryText,
    required this.constraintsSummaryText,
    required this.cuisineSummaryText,
  });

  final int groupSize;
  final int budgetPerPerson;
  final List<String> restrictionValues;
  final int? cuisineTypeId;
  final LuckBoxSuggestResponseModel initialResponse;
  final String budgetSummaryText;
  final String constraintsSummaryText;
  final String cuisineSummaryText;

  SuggestLuckBoxParams toSuggestParams({
    required double? latitude,
    required double? longitude,
  }) {
    return SuggestLuckBoxParams(
      groupSize: groupSize,
      budgetPerPerson: budgetPerPerson,
      restrictions: restrictionValues,
      latitude: latitude,
      longitude: longitude,
      cuisineTypeId: cuisineTypeId,
    );
  }
}
