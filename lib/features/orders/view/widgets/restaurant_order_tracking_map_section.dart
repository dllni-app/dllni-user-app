import 'package:flutter/material.dart';

import '../../data/models/orders_api_models.dart';

/// Map area when tracking API enables it; uses coordinates when present.
class RestaurantOrderTrackingMapSection extends StatelessWidget {
  const RestaurantOrderTrackingMapSection({super.key, required this.map});

  final RestaurantOrderTrackingMapModel map;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xffE0E7FF), Color(0xffDBEAFE), Color(0xffBFDBFE)],
          ),
        ),
        child: Stack(
          children: [
            if (map.hasCoordinates)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.blue.shade900, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        '${map.lat!.toStringAsFixed(5)}, ${map.lng!.toStringAsFixed(5)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              Center(
                child: Icon(Icons.map_outlined, color: Colors.white.withAlpha(220), size: 56),
              ),
            Positioned(
              right: 24,
              top: 36,
              child: Icon(Icons.location_pin, color: Colors.white.withAlpha(230), size: 40),
            ),
            Positioned(
              left: 28,
              top: 48,
              child: Icon(Icons.two_wheeler, color: Colors.white.withAlpha(230), size: 44),
            ),
          ],
        ),
      ),
    );
  }
}
