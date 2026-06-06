import 'dart:convert';

import '../../domain/models/cl_worker_room_assignment_result.dart';

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry('$key', val));
  }
  return const <String, dynamic>{};
}

int? _extractOrderId(Map<String, dynamic> json) {
  final direct = _toInt(json['orderId'] ?? json['order_id']);
  if (direct != null) return direct;

  final data = _toMap(json['data']);
  if (data.isNotEmpty) {
    final dataId = _toInt(data['id'] ?? data['orderId'] ?? data['order_id']);
    if (dataId != null) return dataId;

    final nestedOrder = _toMap(data['order']);
    final nestedOrderId = _toInt(
      nestedOrder['id'] ?? nestedOrder['orderId'] ?? nestedOrder['order_id'],
    );
    if (nestedOrderId != null) return nestedOrderId;

    final nestedCleaningOrder = _toMap(
      data['cleaningOrder'] ?? data['cleaning_order'],
    );
    final nestedCleaningOrderId = _toInt(
      nestedCleaningOrder['id'] ??
          nestedCleaningOrder['orderId'] ??
          nestedCleaningOrder['order_id'],
    );
    if (nestedCleaningOrderId != null) return nestedCleaningOrderId;
  }

  final order = _toMap(json['order']);
  final orderId = _toInt(order['id'] ?? order['orderId'] ?? order['order_id']);
  if (orderId != null) return orderId;

  final cleaningOrder = _toMap(json['cleaningOrder'] ?? json['cleaning_order']);
  return _toInt(
    cleaningOrder['id'] ??
        cleaningOrder['orderId'] ??
        cleaningOrder['order_id'],
  );
}

List<CleaningWorkerRoomAssignment> _extractWorkerRoomAssignments(
  Map<String, dynamic> json,
) {
  final direct = parseWorkerRoomAssignments(
    json['workerRoomAssignments'] ?? json['worker_room_assignments'],
  );
  if (direct.isNotEmpty) return direct;

  final data = _toMap(json['data']);
  if (data.isNotEmpty) {
    final dataAssignments = parseWorkerRoomAssignments(
      data['workerRoomAssignments'] ?? data['worker_room_assignments'],
    );
    if (dataAssignments.isNotEmpty) return dataAssignments;

    final nestedOrder = _toMap(data['order']);
    final nestedOrderAssignments = parseWorkerRoomAssignments(
      nestedOrder['workerRoomAssignments'] ??
          nestedOrder['worker_room_assignments'],
    );
    if (nestedOrderAssignments.isNotEmpty) return nestedOrderAssignments;
  }

  final order = _toMap(json['order']);
  return parseWorkerRoomAssignments(
    order['workerRoomAssignments'] ?? order['worker_room_assignments'],
  );
}

CreateCleaningOrderResponseModel createCleaningOrderResponseModelFromJson(
  dynamic json,
) {
  if (json == null) {
    return const CreateCleaningOrderResponseModel(success: true);
  }
  if (json is String) {
    if (json.isEmpty) {
      return const CreateCleaningOrderResponseModel(success: true);
    }
    return CreateCleaningOrderResponseModel.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }
  if (json is Map<String, dynamic>) {
    return CreateCleaningOrderResponseModel.fromJson(json);
  }
  return const CreateCleaningOrderResponseModel(success: true);
}

class CreateCleaningOrderResponseModel {
  final bool success;
  final String? message;
  final int? orderId;
  final List<CleaningWorkerRoomAssignment> workerRoomAssignments;

  const CreateCleaningOrderResponseModel({
    required this.success,
    this.message,
    this.orderId,
    this.workerRoomAssignments = const [],
  });

  factory CreateCleaningOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateCleaningOrderResponseModel(
      success: (json['success'] as bool?) ?? true,
      message: json['message'] as String?,
      orderId: _extractOrderId(json),
      workerRoomAssignments: _extractWorkerRoomAssignments(json),
    );
  }
}
