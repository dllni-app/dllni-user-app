import 'dart:convert';

CreateCleaningOrderResponseModel createCleaningOrderResponseModelFromJson(dynamic json) {
  if (json == null) {
    return const CreateCleaningOrderResponseModel(success: true);
  }
  if (json is String) {
    if (json.isEmpty) {
      return const CreateCleaningOrderResponseModel(success: true);
    }
    return CreateCleaningOrderResponseModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }
  if (json is Map<String, dynamic>) {
    return CreateCleaningOrderResponseModel.fromJson(json);
  }
  return const CreateCleaningOrderResponseModel(success: true);
}

class CreateCleaningOrderResponseModel {
  final bool success;
  final String? message;

  const CreateCleaningOrderResponseModel({
    required this.success,
    this.message,
  });

  factory CreateCleaningOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateCleaningOrderResponseModel(
      success: (json['success'] as bool?) ?? true,
      message: json['message'] as String?,
    );
  }
}
