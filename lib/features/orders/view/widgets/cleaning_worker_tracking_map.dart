import 'dart:async';
import 'dart:developer';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/map/osrm_route_service.dart';
import 'package:dllni_user_app/core/realtime/cleaning_realtime_contract.dart';
import 'package:dllni_user_app/core/realtime/cleaning_tracking_session_bus.dart';
import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CleaningWorkerTrackingMap extends StatefulWidget {
  const CleaningWorkerTrackingMap({
    super.key,
    required this.customerLatLng,
    required this.bookingStatus,
    this.workerLatLng,
    this.hasStartedTravel = false,
  });

  final LatLng customerLatLng;
  final LatLng? workerLatLng;
  final String bookingStatus;
  final bool hasStartedTravel;

  @override
  State<CleaningWorkerTrackingMap> createState() =>
      _CleaningWorkerTrackingMapState();
}

class _CleaningWorkerTrackingMapState extends State<CleaningWorkerTrackingMap> {
  static const int _legacyWorkerKey = -1;
  static const double _routeRefreshDistanceMeters = 35;
  static const Duration _persistedRefreshInterval = Duration(seconds: 15);

  final MapController _mapController = MapController();
  final Map<int, _TrackingWorkerState> _workers =
      <int, _TrackingWorkerState>{};
  final Map<int, LatLng> _lastRoutedLocations = <int, LatLng>{};
  final Map<int, List<LatLng>> _roadRoutes = <int, List<LatLng>>{};
  final Map<int, int> _routeRequestVersions = <int, int>{};
  final Set<int> _loadingRouteKeys = <int>{};

  StreamSubscription<CleaningRealtimeLocation>? _locationSubscription;
  StreamSubscription<int?>? _activeBookingSubscription;
  StreamSubscription<int>? _refreshSubscription;
  Timer? _persistedRefreshTimer;

  int? _bookingId;
  bool _persistedFetchInFlight = false;

  @override
  void initState() {
    super.initState();
    _seedLegacyWorkerLocation(widget.workerLatLng);
    _locationSubscription = CleaningRealtimeLocationBus.stream.listen(
      _applyRealtimeLocation,
    );
    _activeBookingSubscription =
        CleaningTrackingSessionBus.activeBookingStream.listen(
      _onActiveBookingChanged,
    );
    _refreshSubscription = CleaningTrackingSessionBus.refreshStream.listen(
      _onRefreshRequested,
    );
    _persistedRefreshTimer = Timer.periodic(
      _persistedRefreshInterval,
      (_) => _refreshActiveBooking(),
    );

    final activeBookingId = CleaningTrackingSessionBus.activeBookingId;
    if (activeBookingId != null) {
      _onActiveBookingChanged(activeBookingId);
    } else {
      _reloadAllRoadRoutes(force: true);
    }
  }

  @override
  void didUpdateWidget(covariant CleaningWorkerTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final customerChanged = _latLngChanged(
      oldWidget.customerLatLng,
      widget.customerLatLng,
    );
    final legacyWorkerChanged = _latLngChanged(
      oldWidget.workerLatLng,
      widget.workerLatLng,
    );

    if (legacyWorkerChanged) {
      _seedLegacyWorkerLocation(widget.workerLatLng);
    }

    if (customerChanged) {
      _roadRoutes.clear();
      _lastRoutedLocations.clear();
      _reloadAllRoadRoutes(force: true);
      return;
    }

    if (legacyWorkerChanged && widget.workerLatLng != null) {
      unawaited(_loadRoadRouteForWorker(_legacyWorkerKey));
    }
  }

  @override
  void dispose() {
    _persistedRefreshTimer?.cancel();
    _locationSubscription?.cancel();
    _activeBookingSubscription?.cancel();
    _refreshSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _onActiveBookingChanged(int? bookingId) {
    if (!mounted) return;
    if (bookingId == null) {
      _bookingId = null;
      return;
    }

    final changed = _bookingId != bookingId;
    _bookingId = bookingId;
    if (changed) {
      _removeIdentifiedWorkers();
    }
    unawaited(_fetchPersistedWorkers(bookingId));
  }

  void _onRefreshRequested(int bookingId) {
    if (bookingId != _bookingId) return;
    unawaited(_fetchPersistedWorkers(bookingId));
  }

  void _refreshActiveBooking() {
    final bookingId = _bookingId;
    if (bookingId == null) return;
    unawaited(_fetchPersistedWorkers(bookingId));
  }

  Future<void> _fetchPersistedWorkers(int bookingId) async {
    if (_persistedFetchInFlight || bookingId != _bookingId) return;
    _persistedFetchInFlight = true;

    try {
      final response = await getIt<DioNetwork>().getData(
        endPoint: '/api/v1/cleaning-bookings/$bookingId/worker-locations',
      );
      if (!mounted || bookingId != _bookingId) return;

      final body = _asStringMap(response.data);
      final rawWorkers = body['data'];
      if (rawWorkers is! List) return;

      final nextWorkers = <int, _TrackingWorkerState>{};
      for (final item in rawWorkers) {
        final parsed = _TrackingWorkerState.tryParse(item);
        if (parsed == null) continue;
        nextWorkers[parsed.workerId] = parsed;
      }

      _replacePersistedWorkers(nextWorkers);
    } catch (error, stackTrace) {
      log(
        'Failed to restore cleaning worker locations for booking $bookingId: $error',
        stackTrace: stackTrace,
      );
    } finally {
      _persistedFetchInFlight = false;
    }
  }

  void _replacePersistedWorkers(Map<int, _TrackingWorkerState> nextWorkers) {
    if (!mounted) return;

    final staleKeys = _workers.keys
        .where((key) => key != _legacyWorkerKey && !nextWorkers.containsKey(key))
        .toList(growable: false);
    final inactiveKeys = nextWorkers.entries
        .where((entry) => !entry.value.isTravelling)
        .map((entry) => entry.key)
        .toList(growable: false);

    setState(() {
      if (nextWorkers.isNotEmpty) {
        _workers.remove(_legacyWorkerKey);
        _removeRouteState(_legacyWorkerKey);
      }
      _workers.removeWhere((key, _) => key != _legacyWorkerKey);
      _workers.addAll(nextWorkers);

      for (final key in <int>{...staleKeys, ...inactiveKeys}) {
        _removeRouteState(key);
      }
    });

    _reloadAllRoadRoutes(force: false);
  }

  void _removeIdentifiedWorkers() {
    if (!mounted) return;
    final keys = _workers.keys
        .where((key) => key != _legacyWorkerKey)
        .toList(growable: false);
    if (keys.isEmpty) return;

    setState(() {
      for (final key in keys) {
        _workers.remove(key);
        _removeRouteState(key);
      }
    });
  }

  void _seedLegacyWorkerLocation(LatLng? workerLatLng) {
    if (workerLatLng == null) {
      _workers.remove(_legacyWorkerKey);
      _removeRouteState(_legacyWorkerKey);
      return;
    }

    if (_workers.keys.any((key) => key != _legacyWorkerKey)) return;
    _workers[_legacyWorkerKey] = _TrackingWorkerState(
      workerId: _legacyWorkerKey,
      location: workerLatLng,
      startedTravelAt: widget.hasStartedTravel ? DateTime.now() : null,
    );
  }

  void _applyRealtimeLocation(CleaningRealtimeLocation location) {
    if (!mounted) return;

    final activeBookingId = _bookingId;
    if (location.bookingId != null &&
        activeBookingId != null &&
        location.bookingId != activeBookingId) {
      return;
    }

    final workerKey = location.workerId ?? _legacyWorkerKey;
    final nextLocation = LatLng(location.latitude, location.longitude);
    final existing = _workers[workerKey];

    setState(() {
      if (location.workerId != null) {
        _workers.remove(_legacyWorkerKey);
        _removeRouteState(_legacyWorkerKey);
      }
      _workers[workerKey] = (existing ??
              _TrackingWorkerState(
                workerId: workerKey,
                startedTravelAt: DateTime.now(),
              ))
          .copyWith(
        location: nextLocation,
        locationUpdatedAt: _tryDate(location.updatedAt) ?? DateTime.now(),
      );
    });

    unawaited(_loadRoadRouteForWorker(workerKey));
  }

  bool _latLngChanged(LatLng? a, LatLng? b) {
    if (a == null && b == null) return false;
    if (a == null || b == null) return true;
    return a.latitude != b.latitude || a.longitude != b.longitude;
  }

  void _reloadAllRoadRoutes({bool force = false}) {
    for (final entry in _workers.entries.toList(growable: false)) {
      if (!entry.value.isTravelling || entry.value.location == null) {
        _removeRouteState(entry.key);
        continue;
      }
      unawaited(_loadRoadRouteForWorker(entry.key, force: force));
    }
  }

  Future<void> _loadRoadRouteForWorker(
    int workerKey, {
    bool force = false,
  }) async {
    final worker = _workers[workerKey];
    final workerLocation = worker?.location;
    if (worker == null || !worker.isTravelling || workerLocation == null) {
      _removeRouteState(workerKey);
      return;
    }

    final previousRoutedLocation = _lastRoutedLocations[workerKey];
    if (!force && previousRoutedLocation != null) {
      final movedMeters = const Distance()(previousRoutedLocation, workerLocation);
      if (movedMeters < _routeRefreshDistanceMeters) return;
    }

    final requestVersion = (_routeRequestVersions[workerKey] ?? 0) + 1;
    _routeRequestVersions[workerKey] = requestVersion;

    if (mounted) {
      setState(() => _loadingRouteKeys.add(workerKey));
    }

    List<LatLng> points;
    try {
      points = await resolveRoadRoutePoints(
        apiRoutePoints: const <LatLng>[],
        fallbackWaypoints: <LatLng>[
          workerLocation,
          widget.customerLatLng,
        ],
      );
    } catch (_) {
      points = <LatLng>[workerLocation, widget.customerLatLng];
    }

    if (!mounted || _routeRequestVersions[workerKey] != requestVersion) return;

    final currentWorker = _workers[workerKey];
    final currentLocation = currentWorker?.location;
    if (currentWorker == null ||
        !currentWorker.isTravelling ||
        currentLocation == null) {
      _removeRouteState(workerKey);
      return;
    }

    setState(() {
      _roadRoutes[workerKey] = points.length >= 2
          ? points
          : <LatLng>[currentLocation, widget.customerLatLng];
      _lastRoutedLocations[workerKey] = currentLocation;
      _loadingRouteKeys.remove(workerKey);
    });
  }

  void _removeRouteState(int workerKey) {
    _roadRoutes.remove(workerKey);
    _lastRoutedLocations.remove(workerKey);
    _loadingRouteKeys.remove(workerKey);
    _routeRequestVersions[workerKey] =
        (_routeRequestVersions[workerKey] ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.bookingStatus.toLowerCase();
    if (status == CleaningBookingStatus.completed ||
        status == CleaningBookingStatus.cancelled) {
      return const SizedBox.shrink();
    }

    final travellingWorkers = _workers.entries
        .where(
          (entry) => entry.value.isTravelling && entry.value.location != null,
        )
        .toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    final showTravelStatus = widget.hasStartedTravel || _workers.isNotEmpty;
    final travelStatusText = _travelStatusText(travellingWorkers);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTravelStatus) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F5F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.near_me_rounded,
                  color: Color(0xff0CBBC7),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    travelStatusText,
                    style: const TextStyle(
                      color: Color(0xff0F766E),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 220,
            child: Stack(
              children: [
                FlutterMap(
                  key: ValueKey<String>(
                    'cleaning-tracking-${_bookingId ?? 0}',
                  ),
                  mapController: _mapController,
                  options: MapOptions(
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom |
                          InteractiveFlag.drag,
                    ),
                    initialCenter: widget.customerLatLng,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.dllni.user',
                    ),
                    if (_roadRoutes.isNotEmpty)
                      PolylineLayer(
                        polylines: _roadRoutes.entries
                            .where((entry) => entry.value.length >= 2)
                            .map(
                              (entry) => Polyline(
                                points: entry.value,
                                strokeWidth: 4,
                                color: const Color(0xff0CBBC7),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: widget.customerLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.home_rounded,
                            color: Color(0xff1E2A78),
                            size: 34,
                          ),
                        ),
                        for (var index = 0;
                            index < travellingWorkers.length;
                            index++)
                          Marker(
                            point: travellingWorkers[index].value.location!,
                            width: 44,
                            height: 44,
                            child: _WorkerMarker(
                              number: travellingWorkers.length > 1
                                  ? index + 1
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (_loadingRouteKeys.isNotEmpty || _persistedFetchInFlight)
                  const PositionedDirectional(
                    top: 10,
                    end: 10,
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '© OpenStreetMap contributors',
          textAlign: TextAlign.end,
          style: TextStyle(fontSize: 11, color: Color(0xff9CA3AF)),
        ),
      ],
    );
  }

  String _travelStatusText(
    List<MapEntry<int, _TrackingWorkerState>> travellingWorkers,
  ) {
    final states = _workers.values.toList(growable: false);
    final waiting = states.where((worker) => worker.isWaitingToTravel).length;
    final travelling = states.where((worker) => worker.isTravelling).length;
    final arrived = states.where((worker) => worker.hasArrived).length;

    if (states.length > 1) {
      final parts = <String>[
        if (travelling > 0) '$travelling في الطريق إليك',
        if (arrived > 0) '$arrived وصلوا',
        if (waiting > 0) '$waiting بانتظار بدء التحرك',
      ];
      return parts.isEmpty
          ? 'يتم تحديث حالة فريق العمل'
          : 'فريق العمل: ${parts.join('، ')}';
    }

    if (arrived > 0) return 'وصل مقدم الخدمة إلى موقعك';
    if (waiting > 0) return 'بانتظار بدء تحرك مقدم الخدمة';
    if (travellingWorkers.isEmpty) {
      return 'مقدم الخدمة بدأ التحرك، جارٍ تحديد الموقع...';
    }

    final workerLocation = travellingWorkers.first.value.location!;
    final distanceKm =
        const Distance()(widget.customerLatLng, workerLocation) / 1000;
    return 'مقدم الخدمة في الطريق إليك - يبعد تقريباً ${distanceKm.toStringAsFixed(1)} كم';
  }

  Map<String, dynamic> _asStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }

  DateTime? _tryDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class _TrackingWorkerState {
  const _TrackingWorkerState({
    required this.workerId,
    this.status,
    this.location,
    this.startedTravelAt,
    this.arrivedAt,
    this.locationUpdatedAt,
  });

  final int workerId;
  final String? status;
  final LatLng? location;
  final DateTime? startedTravelAt;
  final DateTime? arrivedAt;
  final DateTime? locationUpdatedAt;

  bool get isWaitingToTravel => startedTravelAt == null && arrivedAt == null;
  bool get isTravelling => startedTravelAt != null && arrivedAt == null;
  bool get hasArrived => arrivedAt != null;

  _TrackingWorkerState copyWith({
    String? status,
    LatLng? location,
    DateTime? startedTravelAt,
    DateTime? arrivedAt,
    DateTime? locationUpdatedAt,
  }) {
    return _TrackingWorkerState(
      workerId: workerId,
      status: status ?? this.status,
      location: location ?? this.location,
      startedTravelAt: startedTravelAt ?? this.startedTravelAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      locationUpdatedAt: locationUpdatedAt ?? this.locationUpdatedAt,
    );
  }

  static _TrackingWorkerState? tryParse(dynamic value) {
    final map = _asMap(value);
    final workerId = _asInt(map['workerId'] ?? map['worker_id']);
    if (workerId == null) return null;

    final latitude = _asDouble(map['latitude']);
    final longitude = _asDouble(map['longitude']);

    return _TrackingWorkerState(
      workerId: workerId,
      status: map['status']?.toString(),
      location: latitude == null || longitude == null
          ? null
          : LatLng(latitude, longitude),
      startedTravelAt: _asDate(
        map['startedTravelAt'] ?? map['started_travel_at'],
      ),
      arrivedAt: _asDate(map['arrivedAt'] ?? map['arrived_at']),
      locationUpdatedAt: _asDate(map['updatedAt'] ?? map['updated_at']),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static DateTime? _asDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class _WorkerMarker extends StatelessWidget {
  const _WorkerMarker({this.number});

  final int? number;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(
          child: Icon(
            Icons.person_pin_circle_rounded,
            color: Color(0xff0CBBC7),
            size: 40,
          ),
        ),
        if (number != null)
          PositionedDirectional(
            top: -2,
            end: -2,
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xff1E2A78),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
