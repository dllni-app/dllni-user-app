import 'package:flutter/material.dart';

/// Bundled illustration map from the Alnadha Customer V7 Pen handoff.
/// These are generic editorial illustrations, never worker identity or proof
/// of a booked service. Missing names fall back to relevant neutral imagery.
abstract final class V7Artwork {
  static const root = 'assets/images/v7/';
  static const categoryCleaning = '${root}category-cleaning.png';
  static const categoryRestaurant = '${root}category-restaurant.png';
  static const categorySupermarket = '${root}category-supermarket.png';
  static const categoryDelivery = '${root}category-delivery.png';
  static const cleaningPhoto = '${root}photo-cleaning-action.jpg';
  static const cleaningHome = '${root}photo-home.jpg';
  static const cleaningTools = '${root}photo-cleaning-tools.jpg';
  static const restaurantPhoto = '${root}photo-restaurant.jpg';
  static const groceryPhoto = '${root}photo-groceries.jpg';
  static const empty = '${root}state-empty.png';
  static const offline = '${root}state-offline.png';
  static const address = '${root}state-address.png';
  static const support = '${root}state-support.png';
  static const coupon = '${root}state-coupon.png';
  static const success = '${root}state-success.png';
  static const worker = '${root}worker-fallback.png';

  static String section(String? raw) {
    final value = (raw ?? '').toLowerCase();
    if (value.contains('restaurant') || value.contains('مطعم')) {
      return categoryRestaurant;
    }
    if (value.contains('supermarket') ||
        value.contains('سوبر') ||
        value.contains('بقال')) {
      return categorySupermarket;
    }
    if (value.contains('delivery') || value.contains('توصيل')) {
      return categoryDelivery;
    }
    return categoryCleaning;
  }

  static String cleaningMode(String? raw) {
    final value = (raw ?? '').toLowerCase();
    if (value.contains('deep') || value.contains('عميق')) {
      return '${root}service-deep.png';
    }
    if (value.contains('event') ||
        value.contains('مناسب') ||
        value.contains('احتفال')) {
      return '${root}service-event.png';
    }
    if (value.contains('urgent') || value.contains('مستعجل')) {
      return '${root}service-urgent.png';
    }
    if (value.contains('repeat') || value.contains('متكرر')) {
      return '${root}service-repeat.png';
    }
    return '${root}service-regular.png';
  }

  static String property(String? raw) {
    final value = (raw ?? '').toLowerCase();
    if (value.contains('villa') || value.contains('فيلا')) {
      return '${root}property-villa.png';
    }
    if (value.contains('office') || value.contains('مكتب')) {
      return '${root}property-office.png';
    }
    return '${root}property-apartment.png';
  }

  static String task(String? raw) {
    final value = (raw ?? '').toLowerCase();
    if (value.contains('window') ||
        value.contains('نافذ') ||
        value.contains('شباك')) {
      return '${root}task-window.png';
    }
    if (value.contains('fridge') || value.contains('ثلاج')) {
      return '${root}task-fridge.png';
    }
    if (value.contains('oven') || value.contains('فرن')) {
      return '${root}task-oven.png';
    }
    if (value.contains('laundry') || value.contains('غسيل')) {
      return '${root}task-laundry.png';
    }
    if (value.contains('iron') || value.contains('كي ')) {
      return '${root}task-ironing.png';
    }
    if (value.contains('bath') || value.contains('حمام')) {
      return '${root}room-bathroom.png';
    }
    if (value.contains('kitchen') || value.contains('مطبخ')) {
      return '${root}room-kitchen.png';
    }
    if (value.contains('bed') || value.contains('نوم')) {
      return '${root}room-bedroom.png';
    }
    if (value.contains('living') || value.contains('صالون')) {
      return '${root}room-living.png';
    }
    return '${root}task-floor.png';
  }
}

/// A consistent expressive illustration frame with a safe fallback.
class V7ArtTile extends StatelessWidget {
  const V7ArtTile({
    super.key,
    required this.asset,
    this.size = 68,
    this.background = const Color(0xFFF0F8F8),
    this.radius = 18,
  });

  final String asset;
  final double size;
  final Color background;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: const EdgeInsets.all(5),
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.cleaning_services_outlined,
            color: Color(0xFF172554),
            size: 28,
          ),
        ),
      ),
    );
  }
}
