import 'dart:convert';

import 'package:common_package/helpers/logger_interceptor.dart';
import 'package:common_package/helpers/pusher_service_logger.dart';
import 'package:common_package/helpers/shared_preferences_helper.dart';
import 'package:dio/dio.dart';
import 'package:dllni_user_app/core/app_config.dart';
import 'package:injectable/injectable.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

typedef CleaningBookingEventHandler =
    void Function(String eventName, Map<String, dynamic> payload);

@lazySingleton
class CleaningBookingPusherService {
  CleaningBookingPusherService() {
    _broadcastAuthDio.interceptors.add(LoggerInterceptor());
  }

  final Dio _broadcastAuthDio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      responseType: ResponseType.json,
      contentType: Headers.formUrlEncodedContentType,
    ),
  );
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

  bool _initialized = false;
  String? _activeBookingChannel;
  final Map<int, CleaningBookingEventHandler> _bookingHandlers = {};

  void setBookingHandler(int bookingId, CleaningBookingEventHandler? onEvent) {
    if (onEvent == null) {
      _bookingHandlers.remove(bookingId);
      return;
    }
    _bookingHandlers[bookingId] = onEvent;
  }

  Future<void> ensureInitialized() async {
    await _ensureInit();
  }

  Future<void> _ensureInit() async {
    if (AppConfig.pusherKey.isEmpty) {
      PusherServiceLogger.skippedNoPusherKey();
      return;
    }
    if (_initialized) return;

    PusherServiceLogger.init(
      cluster: AppConfig.pusherCluster,
      authEndpoint: '${AppConfig.baseUrl}/broadcasting/auth',
      hasApiKey: AppConfig.pusherKey.isNotEmpty,
    );

    await _pusher.init(
      apiKey: AppConfig.pusherKey,
      cluster: AppConfig.pusherCluster,
      useTLS: true,
      onConnectionStateChange: (current, previous) {
        PusherServiceLogger.connectionStateChange(current, previous);
      },
      onSubscriptionSucceeded: (channelName, data) {
        PusherServiceLogger.subscriptionSucceeded(channelName, data);
      },
      onAuthorizer: (channelName, socketId, dynamic options) async {
        try {
          final token = (SharedPreferencesHelper.getData(key: 'token') ?? '')
              .toString();
          final res = await _broadcastAuthDio.post<Map<String, dynamic>>(
            '/broadcasting/auth',
            data: <String, dynamic>{
              'channel_name': channelName,
              'socket_id': socketId,
            },
            options: Options(
              headers: <String, dynamic>{
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                if (token.isNotEmpty) 'Authorization': 'Bearer $token',
              },
              contentType: Headers.formUrlEncodedContentType,
              responseType: ResponseType.json,
            ),
          );
          final body = res.data;
          if (body == null || body['auth'] == null) {
            throw StateError('Invalid broadcasting auth response');
          }
          return <String, dynamic>{
            'auth': body['auth'],
            if (body['channel_data'] != null)
              'channel_data': body['channel_data'],
          };
        } catch (e, st) {
          PusherServiceLogger.authAuthorizerError(channelName, e, st);
          rethrow;
        }
      },
      onSubscriptionError: (message, e) {
        PusherServiceLogger.subscriptionError('(subscription)', message, e);
      },
      onError: (message, code, e) {
        PusherServiceLogger.socketError(message, code, e);
      },
      onEvent: _handleEvent,
    );

    PusherServiceLogger.connect();
    await _pusher.connect();
    _initialized = true;
  }

  void _handleEvent(PusherEvent event) {
    PusherServiceLogger.event(
      event.channelName,
      event.eventName,
      event.data,
    );
    final channel = event.channelName;
    if (!channel.startsWith('private-cleaning-booking.')) return;
    final bookingId = int.tryParse(channel.split('.').last);
    if (bookingId == null) return;
    _bookingHandlers[bookingId]?.call(
      event.eventName,
      _parsePayload(event.data),
    );
  }

  Map<String, dynamic> _parsePayload(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {}
    }
    return const {};
  }

  Future<void> subscribeBookingChannel(int bookingId) async {
    if (AppConfig.pusherKey.isEmpty) return;
    await _ensureInit();
    final channel = 'private-cleaning-booking.$bookingId';
    if (_activeBookingChannel == channel) return;
    if (_activeBookingChannel != null) {
      PusherServiceLogger.unsubscribe(_activeBookingChannel!);
      await _pusher.unsubscribe(channelName: _activeBookingChannel!);
    }
    _activeBookingChannel = channel;
    PusherServiceLogger.subscribe(channel);
    await _pusher.subscribe(channelName: channel);
  }

  Future<void> unsubscribeBookingChannel(int bookingId) async {
    final channel = 'private-cleaning-booking.$bookingId';
    if (_activeBookingChannel != channel) return;
    PusherServiceLogger.unsubscribe(channel);
    await _pusher.unsubscribe(channelName: channel);
    _activeBookingChannel = null;
  }
}
