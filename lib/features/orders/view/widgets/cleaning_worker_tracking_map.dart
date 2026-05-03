import 'package:dllni_user_app/features/orders/data/models/cleaning_booking_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CleaningWorkerTrackingMap extends StatelessWidget {
  const CleaningWorkerTrackingMap({
    super.key,
    required this.customerLatLng,
    required this.bookingStatus,
    this.workerLatLng,
  });

  final LatLng customerLatLng;
  final LatLng? workerLatLng;
  final String bookingStatus;

  @override
  Widget build(BuildContext context) {
    final status = bookingStatus.toLowerCase();
    if (status == CleaningBookingStatus.completed ||
        status == CleaningBookingStatus.cancelled) {
      return const SizedBox.shrink();
    }

    final points = <LatLng>[
      customerLatLng,
      ...?workerLatLng == null ? null : <LatLng>[workerLatLng!],
    ];
    final center = points.length == 1
        ? customerLatLng
        : LatLng(
            (customerLatLng.latitude + workerLatLng!.latitude) / 2,
            (customerLatLng.longitude + workerLatLng!.longitude) / 2,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: points.length == 1 ? 15 : 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.dllni.user',
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
                        point: workerLatLng!,
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
                if (workerLatLng != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [customerLatLng, workerLatLng!],
                        strokeWidth: 3,
                        color: const Color(0xff0CBBC7),
                      ),
                    ],
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
