class VoteFollowupOptionData {
  const VoteFollowupOptionData({
    required this.optionId,
    required this.name,
    required this.size,
    required this.price,
    required this.progress,
    required this.votes,
  });

  final int? optionId;
  final String name;
  final String size;
  final String price;
  final double progress;
  final int votes;
}
