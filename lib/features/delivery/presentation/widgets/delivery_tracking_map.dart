import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/delivery_order_models.dart';

class DeliveryTrackingMap extends StatelessWidget {
  const DeliveryTrackingMap({super.key, required this.map});

  final DeliveryMapModel map;

  @override
  Widget build(BuildContext context) {
    if (!map.enabled || map.markers.isEmpty) {
      return const SizedBox.shrink();
    }

    final points = map.markers
        .where((m) => m.latitude != null && m.longitude != null)
        .map((m) => LatLng(m.latitude!, m.longitude!))
        .toList();

    if (points.isEmpty) return const SizedBox.shrink();

    final center = map.centerLatitude != null && map.centerLongitude != null
        ? LatLng(map.centerLatitude!, map.centerLongitude!)
        : LatLng(
            points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length,
            points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length,
          );

    final routePoints = map.route
        .where((p) => p.latitude != null && p.longitude != null)
        .map((p) => LatLng(p.latitude!, p.longitude!))
        .toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
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
              markers: map.markers
                  .where((m) => m.latitude != null && m.longitude != null)
                  .map((m) {
                final icon = switch (m.kind) {
                  'pickup' => Icons.store_rounded,
                  'dropoff' => Icons.home_rounded,
                  'driver' => Icons.delivery_dining_rounded,
                  _ => Icons.place_rounded,
                };
                final color = switch (m.kind) {
                  'pickup' => const Color(0xffF59E0B),
                  'dropoff' => const Color(0xff1E2A78),
                  'driver' => const Color(0xff0CBBC7),
                  _ => const Color(0xff6B7280),
                };
                return Marker(
                  point: LatLng(m.latitude!, m.longitude!),
                  width: 40,
                  height: 40,
                  child: Icon(icon, color: color, size: 34),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
