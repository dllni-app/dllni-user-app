import 'dart:convert';

SubmitCleaningReviewModel submitCleaningReviewModelFromJson(dynamic str) =>
    SubmitCleaningReviewModel.fromJson(
      str is String ? json.decode(str) : str as Map<String, dynamic>,
    );

class SubmitCleaningReviewModel {
  SubmitCleaningReviewModel({this.data, this.message});

  final SubmitCleaningReviewData? data;
  final String? message;

  factory SubmitCleaningReviewModel.fromJson(Map<String, dynamic> json) {
    return SubmitCleaningReviewModel(
      data: json['data'] is Map<String, dynamic>
          ? SubmitCleaningReviewData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
      message: json['message']?.toString(),
    );
  }
}

class SubmitCleaningReviewData {
  SubmitCleaningReviewData({this.ok});

  final bool? ok;

  factory SubmitCleaningReviewData.fromJson(Map<String, dynamic> json) {
    return SubmitCleaningReviewData(ok: json['ok'] == true);
  }
}
