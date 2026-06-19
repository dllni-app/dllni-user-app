import 'dart:core';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

import '../generated/locale_keys.g.dart';

mixin HandlingException {
  Future<Either<Failure, T>> wrapHandlingException<T>({required Future<T> Function() tryCall}) async {
    try {
      final result = await tryCall();
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handle(e).failure);
    }
  }
}

class ErrorHandler implements Exception {
  late Failure failure;

  ErrorHandler.handle(error) {
    if (error is DioException) {
      failure = _handleError(error);
    } else {
      failure = ServerFailure(message: error.toString(), statusCode: ResponseCode.badRequestServer);
    }
  }

  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return DataSource.connectTimeOut.getFailure();
      case DioExceptionType.sendTimeout:
        return DataSource.sendTimeOut.getFailure();
      case DioExceptionType.receiveTimeout:
        return DataSource.receiveTimeOut.getFailure();
      case DioExceptionType.cancel:
        return DataSource.cancel.getFailure();
      case DioExceptionType.unknown:
        return DataSource.def.getFailure();
      case DioExceptionType.badCertificate:
        return DataSource.badRequest.getFailure();
      case DioExceptionType.connectionError:
        return DataSource.noInternetConnection.getFailure();
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case ResponseCode.unAuthorized:
            return _apiFailure(error, unauthenticated: true);
          case ResponseCode.forBidden:
          case ResponseCode.conflict:
          case ResponseCode.gone:
            return _apiFailure(error);
          case ResponseCode.internalServerError:
            return DataSource.internetServerError.getFailure();
          case ResponseCode.notFound:
            return _apiFailure(error, fallback: DataSource.notFound.getFailure());
          case ResponseCode.blocked:
            return UserBlockedFailure(message: AppConstants.blockedError.tr());
          case ResponseCode.notAllowed:
            return UserNotAllowedFailure(message: AppConstants.notAllowed.tr());
          case ResponseCode.badContent:
          case ResponseCode.badRequestServer:
            return _apiFailure(error);
          default:
            return _apiFailure(error);
        }
    }
  }
}

Failure _apiFailure(
  DioException error, {
  bool unauthenticated = false,
  Failure? fallback,
}) {
  final responseData = error.response?.data;
  final statusCode = error.response?.statusCode ?? ResponseCode.badRequest;

  if (responseData is Map<String, dynamic>) {
    final message = ErrorMessageModel.fromJson(responseData).statusMessage;
    final code = responseData['code']?.toString();
    final dataRaw = responseData['data'];
    final data = dataRaw is Map ? Map<String, dynamic>.from(dataRaw) : null;

    if (unauthenticated) {
      return UnauthenticatedFailure(
        message: message,
        statusCode: statusCode,
        code: code,
        data: data,
      );
    }

    return ServerFailure(
      message: message,
      statusCode: statusCode,
      code: code,
      data: data,
      fieldErrors: _parseFieldErrors(responseData),
    );
  }

  if (fallback != null) return fallback;

  return ServerFailure(
    message: responseData is Map
        ? responseData['message']?.toString() ?? responseData['errors']?.toString() ?? ''
        : responseData?.toString() ?? '',
    statusCode: statusCode,
  );
}

Map<String, List<String>>? _parseFieldErrors(dynamic data) {
  if (data is! Map<String, dynamic>) return null;

  final errorsRaw = data['errors'];
  if (errorsRaw is! Map) return null;

  final fieldErrors = <String, List<String>>{};
  for (final entry in errorsRaw.entries) {
    final key = entry.key.toString();
    final value = entry.value;
    if (value is List) {
      fieldErrors[key] = value.map((item) => item.toString()).toList(growable: false);
    } else if (value != null) {
      fieldErrors[key] = [value.toString()];
    }
  }

  return fieldErrors.isEmpty ? null : fieldErrors;
}

extension DataSourceExtension on DataSource {
  Failure getFailure() {
    switch (this) {
      case DataSource.success:
        return ServerFailure(statusCode: ResponseCode.success, message: ResponseMessage.success.tr());
      case DataSource.noInternet:
        return ServerFailure(statusCode: ResponseCode.noContent, message: ResponseMessage.noContent.tr());
      case DataSource.badRequest:
        return ServerFailure(statusCode: ResponseCode.badRequest, message: ResponseMessage.badRequest.tr());
      case DataSource.forBidden:
        return ServerFailure(statusCode: ResponseCode.forBidden, message: ResponseMessage.forbidden.tr());
      case DataSource.unAuthorized:
        return ServerFailure(statusCode: ResponseCode.unAuthorized, message: ResponseMessage.unAuthorized.tr());
      case DataSource.notFound:
        return ServerFailure(statusCode: ResponseCode.notFound, message: ResponseMessage.notFound.tr());
      case DataSource.internetServerError:
        return ServerFailure(statusCode: ResponseCode.internalServerError, message: ResponseMessage.internalServerError.tr());
      case DataSource.connectTimeOut:
        return ServerFailure(statusCode: ResponseCode.connectTimeOut, message: ResponseMessage.connectTimeout.tr());
      case DataSource.cancel:
        return ServerFailure(statusCode: ResponseCode.cancel, message: ResponseMessage.cancel.tr());
      case DataSource.receiveTimeOut:
        return ServerFailure(statusCode: ResponseCode.receiveTimeOut, message: ResponseMessage.receiveTime.tr());
      case DataSource.sendTimeOut:
        return ServerFailure(statusCode: ResponseCode.sendTimeOut, message: ResponseMessage.sendTimeout.tr());
      case DataSource.cashError:
        return ServerFailure(statusCode: ResponseCode.cashError, message: ResponseMessage.cacheError.tr());
      case DataSource.noInternetConnection:
        return ServerFailure(statusCode: ResponseCode.noInternetConnection, message: ResponseMessage.noInternetConnection.tr());
      case DataSource.def:
        return ServerFailure(statusCode: ResponseCode.def, message: ResponseMessage.def.tr());
    }
  }
}

class ResponseCode {
  static const int success = 200;
  static const int noContent = 201;
  static const int badRequest = 400;
  static const int unAuthorized = 401;
  static const int forBidden = 403;
  static const int conflict = 409;
  static const int gone = 410;
  static const int internalServerError = 500;
  static const int notFound = 404;
  static const int notAllowed = 405;
  static const int blocked = 420;
  static const int badContent = 422;
  static const int badRequestServer = 402;
  static const int connectTimeOut = -1;
  static const int cancel = -2;
  static const int receiveTimeOut = -3;
  static const int sendTimeOut = -4;
  static const int cashError = -5;
  static const int noInternetConnection = -6;
  static const int def = -7;
}

class ResponseMessage {
  static const String success = AppConstants.success;
  static const String noContent = AppConstants.success;
  static const String badRequest = AppConstants.badRequestError;
  static const String unAuthorized = AppConstants.unauthorizedError;
  static const String forbidden = AppConstants.forbiddenError;
  static const String internalServerError = AppConstants.internalServerError;
  static const String notFound = AppConstants.notFoundError;
  static const String connectTimeout = AppConstants.timeoutError;
  static const String cancel = AppConstants.defaultError;
  static const String receiveTime = AppConstants.timeoutError;
  static const String sendTimeout = AppConstants.timeoutError;
  static const String cacheError = AppConstants.cacheError;
  static const String noInternetConnection = AppConstants.noInternetError;
  static const String def = AppConstants.defaultError;
}

class AppConstants {
  AppConstants._();

  static const String success = LocaleKeys.errorMessage_success;
  static const String badRequestError = LocaleKeys.errorMessage_badRequestError;
  static const String noContent = LocaleKeys.errorMessage_noContent;
  static const String forbiddenError = LocaleKeys.errorMessage_forbiddenError;
  static const String unauthorizedError = LocaleKeys.errorMessage_unauthorizedError;
  static const String notFoundError = LocaleKeys.errorMessage_notFoundError;
  static const String conflictError = LocaleKeys.errorMessage_conflictError;
  static const String blockedError = LocaleKeys.errorMessage_blockedError;
  static const String internalServerError = LocaleKeys.errorMessage_internalServerError;
  static const String notAllowed = LocaleKeys.errorMessage_notAllowed;

  static const String unknownError = LocaleKeys.errorMessage_unknownError;
  static const String timeoutError = LocaleKeys.errorMessage_timeoutError;
  static const String defaultError = LocaleKeys.errorMessage_defaultError;
  static const String cacheError = LocaleKeys.errorMessage_cacheError;
  static const String noInternetError = LocaleKeys.errorMessage_noInternetError;
}

class ApiInternalStatus {
  static const int success = 0;
  static const int failure = 1;
}

enum DataSource {
  success,
  noInternet,
  badRequest,
  forBidden,
  unAuthorized,
  notFound,
  internetServerError,
  connectTimeOut,
  cancel,
  receiveTimeOut,
  sendTimeOut,
  cashError,
  noInternetConnection,
  def,
}

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? data;

  const Failure({
    required this.message,
    this.statusCode = -1,
    this.code,
    this.data,
  });

  @override
  List<Object?> get props => [message, statusCode, code, data];
}

class ServerFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ServerFailure({
    required super.message,
    super.statusCode,
    super.code,
    super.data,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, statusCode, code, data, fieldErrors];
}

class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure({
    required super.message,
    super.statusCode,
    super.code,
    super.data,
  });
}

class UserNotAllowedFailure extends Failure {
  const UserNotAllowedFailure({required super.message});
}

class UserBlockedFailure extends Failure {
  const UserBlockedFailure({required super.message});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}

class ErrorMessageModel extends Equatable {
  final String statusMessage;
  final bool success;

  const ErrorMessageModel({required this.statusMessage, required this.success});

  factory ErrorMessageModel.fromJson(Map<String, dynamic> json) {
    String error = "";
    if (json["message"] is Map) {
      for (var item in (json["message"] as Map<String, dynamic>).entries) {
        error = "${error.isEmpty ? "" : "$error \n"} ${item.value}";
      }
    } else {
      error = json["message"]?.toString() ?? json["errors"]?.toString() ?? '';
    }
    return ErrorMessageModel(statusMessage: error, success: json["success"] ?? false);
  }

  @override
  List<Object?> get props => [statusMessage, success];
}
