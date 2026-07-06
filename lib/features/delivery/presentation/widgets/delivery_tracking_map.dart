import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/delivery_order_models.dart';

class DeliveryTrackingMap extends StatelessWidget {
  const DeliveryTrackingMap({super.key, required this.map});

  final DeliveryMapModel map;

  @override
  Widget build(BuildContext context) {
    final markers = map.markers
        .where((m) => m.latitude != null && m.longitude != null)
        .toList(growable: false);

    if (!map.enabled || markers.isEmpty) {
      return _MapPlaceholder();
    }

    final points = markers
        .map((m) => LatLng(m.latitude!, m.longitude!))
        .toList();

    final center = _resolveCenter(markers, points);

    final routePoints = map.route
        .where((p) => p.latitude != null && p.longitude != null)
        .map((p) => LatLng(p.latitude!, p.longitude!))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 220,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: map.zoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.dllni.user',
                  ),
                  if (routePoints.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          color: const Color(0xff1E2A78),
                          strokeWidth: 3,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: markers.map((m) {
                      final icon = switch (m.kind) {
                        'pickup' => Icons.store_rounded,
                        'dropoff' => Icons.home_rounded,
                        'driver' => Icons.delivery_dining_rounded,
                        _ => Icons.place_rounded,
                      };
                      final color = _markerColor(m.kind);
                      return Marker(
                        point: LatLng(m.latitude!, m.longitude!),
                        width: 70,
                        height: 58,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, color: color, size: 32),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _markerLabel(m.kind),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: const [
                _MapLegendItem(color: Color(0xffF59E0B), label: 'المتجر / المطعم'),
                _MapLegendItem(color: Color(0xff1E2A78), label: 'عنوانك'),
                _MapLegendItem(color: Color(0xff0CBBC7), label: 'المندوب'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LatLng _resolveCenter(
    List<DeliveryMapMarkerModel> markers,
    List<LatLng> points,
  ) {
    final driver = _firstMarker(markers, 'driver');
    final dropoff = _firstMarker(markers, 'dropoff');

    if (driver != null && dropoff != null) {
      return LatLng(
        (driver.latitude! + dropoff.latitude!) / 2,
        (driver.longitude! + dropoff.longitude!) / 2,
      );
    }

    if (map.centerLatitude != null && map.centerLongitude != null) {
      return LatLng(map.centerLatitude!, map.centerLongitude!);
    }

    return LatLng(
      points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length,
      points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length,
    );
  }

  DeliveryMapMarkerModel? _firstMarker(
    List<DeliveryMapMarkerModel> markers,
    String kind,
  ) {
    for (final marker in markers) {
      if (marker.kind == kind) return marker;
    }
    return null;
  }

  static String _markerLabel(String? kind) {
    return switch (kind) {
      'pickup' => 'الاستلام',
      'dropoff' => 'التسليم',
      'driver' => 'المندوب',
      _ => 'موقع',
    };
  }

  static Color _markerColor(String? kind) {
    return switch (kind) {
      'pickup' => const Color(0xffF59E0B),
      'dropoff' => const Color(0xff1E2A78),
      'driver' => const Color(0xff0CBBC7),
      _ => const Color(0xff6B7280),
    };
  }
}

class _MapLegendItem extends StatelessWidget {
  const _MapLegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xff6B7280)),
        ),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: const Row(
        children: [
          Icon(Icons.map_outlined, color: Color(0xff6B7280)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'سيتم عرض موقع المندوب عند توفر بيانات التتبع.',
              style: TextStyle(color: Color(0xff6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}
