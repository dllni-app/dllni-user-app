import 'package:dllni_user_app/core/map/osrm_route_service.dart';
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
  List<LatLng>? _roadRoutePoints;
  bool _loadingRoute = false;
  int _routeRequestVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadRoadRoute();
  }

  @override
  void didUpdateWidget(covariant CleaningWorkerTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_routeInputsChanged(oldWidget, widget)) {
      _loadRoadRoute();
    }
  }

  bool _routeInputsChanged(
    CleaningWorkerTrackingMap previous,
    CleaningWorkerTrackingMap next,
  ) {
    return _latLngChanged(previous.workerLatLng, next.workerLatLng) ||
        _latLngChanged(previous.customerLatLng, next.customerLatLng);
  }

  bool _latLngChanged(LatLng? a, LatLng? b) {
    if (a == null && b == null) return false;
    if (a == null || b == null) return true;
    return a.latitude != b.latitude || a.longitude != b.longitude;
  }

  Future<void> _loadRoadRoute() async {
    final requestVersion = ++_routeRequestVersion;
    final worker = widget.workerLatLng;
    final customer = widget.customerLatLng;

    if (worker == null) {
      if (!mounted) return;
      setState(() {
        _roadRoutePoints = null;
        _loadingRoute = false;
      });
      return;
    }

    setState(() => _loadingRoute = true);

    final points = await resolveRoadRoutePoints(
      apiRoutePoints: const <LatLng>[],
      fallbackWaypoints: <LatLng>[worker, customer],
    );

    if (!mounted || requestVersion != _routeRequestVersion) return;
    setState(() {
      _roadRoutePoints = points.length >= 2 ? points : <LatLng>[worker, customer];
      _loadingRoute = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.bookingStatus.toLowerCase();
    if (status == CleaningBookingStatus.completed ||
        status == CleaningBookingStatus.cancelled) {
      return const SizedBox.shrink();
    }

    final workerLatLng = widget.workerLatLng;
    final customerLatLng = widget.customerLatLng;
    final points = workerLatLng == null
        ? <LatLng>[customerLatLng]
        : <LatLng>[customerLatLng, workerLatLng];
    final center = workerLatLng == null
        ? customerLatLng
        : LatLng(
            (customerLatLng.latitude + workerLatLng.latitude) / 2,
            (customerLatLng.longitude + workerLatLng.longitude) / 2,
          );
    final routePoints = _roadRoutePoints;
    final travelDistanceKm = workerLatLng == null
        ? null
        : const Distance()(customerLatLng, workerLatLng) / 1000;
    final travelStatusText = travelDistanceKm == null
        ? 'مقدم الخدمة بدأ التحرك، جارٍ تحديد الموقع...'
        : 'مقدم الخدمة في الطريق إليك - يبعد تقريباً ${travelDistanceKm.toStringAsFixed(1)} كم';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.hasStartedTravel) ...[
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
                  options: MapOptions(
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom |
                          InteractiveFlag.drag,
                    ),
                    initialCenter: center,
                    initialZoom: points.length == 1 ? 15 : 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.dllni.user',
                    ),
                    if (routePoints != null && routePoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 4,
                            color: const Color(0xff0CBBC7),
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: customerLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.home_rounded,
                            color: Color(0xff1E2A78),
                            size: 34,
                          ),
                        ),
                        if (workerLatLng != null)
                          Marker(
                            point: workerLatLng,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.person_pin_circle_rounded,
                              color: Color(0xff0CBBC7),
                              size: 36,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (_loadingRoute)
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
}
