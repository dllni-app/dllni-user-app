import '../../data/models/profile_api_models.dart';

class OrderVotingCreatedPollItem {
  const OrderVotingCreatedPollItem({
    required this.title,
    required this.detail,
    required this.voteId,
    required this.initialData,
  });

  final String title;
  final String detail;
  final int voteId;
  final VoteCreatedData initialData;
}
