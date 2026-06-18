import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../data/models/delivery_order_models.dart';

class DeliveryDriverCard extends StatelessWidget {
  const DeliveryDriverCard({super.key, required this.driver});

  final DeliveryDriverModel driver;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xffEEF2FF),
            child: Icon(
              driver.vehicleType == 'motorbike'
                  ? Icons.two_wheeler_rounded
                  : Icons.local_shipping_outlined,
              color: const Color(0xff1E2A78),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1F2937),
                  ),
                ),
                if (driver.vehicleType != null || driver.plateNumber != null)
                  Text(
                    [
                      if (driver.vehicleType != null) driver.vehicleType,
                      if (driver.plateNumber != null) driver.plateNumber,
                    ].join(' • '),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff6B7280),
                    ),
                  ),
                if (driver.trustScore != null)
                  Text(
                    'تقييم الثقة: ${driver.trustScore!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff10B981),
                    ),
                  ),
              ],
            ),
          ),
          if (driver.phone != null && driver.phone!.isNotEmpty)
            IconButton.filled(
              onPressed: () => launchUrlString('tel:${driver.phone}'),
              icon: const Icon(Icons.phone_rounded),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xff1E2A78),
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
