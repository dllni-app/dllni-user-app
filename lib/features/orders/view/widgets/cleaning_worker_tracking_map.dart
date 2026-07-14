import 'dart:async';

import 'package:dllni_user_app/core/map/osrm_route_service.dart';
import 'package:dllni_user_app/core/realtime/cleaning_realtime_contract.dart';
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

  final Map<int, LatLng> _workerLocations = <int, LatLng>{};
  final Map<int, LatLng> _lastRoutedLocations = <int, LatLng>{};
  final Map<int, List<LatLng>> _roadRoutes = <int, List<LatLng>>{};
  final Map<int, int> _routeRequestVersions = <int, int>{};
  final Set<int> _loadingRouteKeys = <int>{};

  StreamSubscription<CleaningRealtimeLocation>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _seedLegacyWorkerLocation(widget.workerLatLng);
    _locationSubscription = CleaningRealtimeLocationBus.stream.listen(
      _applyRealtimeLocation,
    );
    _reloadAllRoadRoutes(force: true);
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
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _seedLegacyWorkerLocation(LatLng? workerLatLng) {
    if (workerLatLng == null) {
      _workerLocations.remove(_legacyWorkerKey);
      _roadRoutes.remove(_legacyWorkerKey);
      _lastRoutedLocations.remove(_legacyWorkerKey);
      return;
    }

    // Once identified worker events are available, do not render an additional
    // anonymous marker for the same single-worker fallback location.
    if (_workerLocations.keys.any((key) => key != _legacyWorkerKey)) return;
    _workerLocations[_legacyWorkerKey] = workerLatLng;
  }

  void _applyRealtimeLocation(CleaningRealtimeLocation location) {
    if (!mounted) return;

    final workerKey = location.workerId ?? _legacyWorkerKey;
    final nextLocation = LatLng(location.latitude, location.longitude);

    setState(() {
      if (location.workerId != null) {
        _workerLocations.remove(_legacyWorkerKey);
        _roadRoutes.remove(_legacyWorkerKey);
        _lastRoutedLocations.remove(_legacyWorkerKey);
      }
      _workerLocations[workerKey] = nextLocation;
    });

    unawaited(_loadRoadRouteForWorker(workerKey));
  }

  bool _latLngChanged(LatLng? a, LatLng? b) {
    if (a == null && b == null) return false;
    if (a == null || b == null) return true;
    return a.latitude != b.latitude || a.longitude != b.longitude;
  }

  void _reloadAllRoadRoutes({bool force = false}) {
    for (final workerKey in _workerLocations.keys.toList(growable: false)) {
      unawaited(_loadRoadRouteForWorker(workerKey, force: force));
    }
  }

  Future<void> _loadRoadRouteForWorker(
    int workerKey, {
    bool force = false,
  }) async {
    final worker = _workerLocations[workerKey];
    if (worker == null) return;

    final previousRoutedLocation = _lastRoutedLocations[workerKey];
    if (!force && previousRoutedLocation != null) {
      final movedMeters = const Distance()(previousRoutedLocation, worker);
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
        fallbackWaypoints: <LatLng>[worker, widget.customerLatLng],
      );
    } catch (_) {
      points = <LatLng>[worker, widget.customerLatLng];
    }

    if (!mounted || _routeRequestVersions[workerKey] != requestVersion) return;

    final currentWorker = _workerLocations[workerKey];
    if (currentWorker == null) return;

    setState(() {
      _roadRoutes[workerKey] = points.length >= 2
          ? points
          : <LatLng>[currentWorker, widget.customerLatLng];
      _lastRoutedLocations[workerKey] = currentWorker;
      _loadingRouteKeys.remove(workerKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.bookingStatus.toLowerCase();
    if (status == CleaningBookingStatus.completed ||
        status == CleaningBookingStatus.cancelled) {
      return const SizedBox.shrink();
    }

    final workers = _workerLocations.entries.toList(growable: false)
      ..sort((a, b) => a.key.compareTo(b.key));
    final visiblePoints = <LatLng>[
      widget.customerLatLng,
      ...workers.map((entry) => entry.value),
    ];
    final center = _averageCenter(visiblePoints);
    final showTravelStatus = widget.hasStartedTravel || workers.isNotEmpty;
    final travelStatusText = _travelStatusText(workers);

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
                  key: ValueKey<String>('cleaning-tracking-${workers.length}'),
                  options: MapOptions(
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom |
                          InteractiveFlag.drag,
                    ),
                    initialCenter: center,
                    initialZoom: workers.isEmpty ? 15 : 13,
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
                        for (var index = 0; index < workers.length; index++)
                          Marker(
                            point: workers[index].value,
                            width: 44,
                            height: 44,
                            child: _WorkerMarker(
                              number: workers.length > 1 ? index + 1 : null,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (_loadingRouteKeys.isNotEmpty)
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

  LatLng _averageCenter(List<LatLng> points) {
    if (points.isEmpty) return widget.customerLatLng;
    final latitude = points.fold<double>(
          0,
          (sum, point) => sum + point.latitude,
        ) /
        points.length;
    final longitude = points.fold<double>(
          0,
          (sum, point) => sum + point.longitude,
        ) /
        points.length;
    return LatLng(latitude, longitude);
  }

  String _travelStatusText(List<MapEntry<int, LatLng>> workers) {
    if (workers.isEmpty) {
      return 'مقدم الخدمة بدأ التحرك، جارٍ تحديد الموقع...';
    }

    if (workers.length > 1) {
      return '${workers.length} من مقدمي الخدمة في الطريق إليك';
    }

    final distanceKm =
        const Distance()(widget.customerLatLng, workers.first.value) / 1000;
    return 'مقدم الخدمة في الطريق إليك - يبعد تقريباً ${distanceKm.toStringAsFixed(1)} كم';
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
