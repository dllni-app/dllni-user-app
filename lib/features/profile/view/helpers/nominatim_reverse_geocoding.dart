import 'package:dio/dio.dart';

class NominatimAddressFields {
  const NominatimAddressFields({
    this.city,
    this.neighborhood,
    this.street,
    this.building,
    this.directions,
    this.displayName,
  });

  final String? city;
  final String? neighborhood;
  final String? street;
  final String? building;
  final String? directions;
  final String? displayName;

  bool get hasAnyData =>
      (city ?? '').isNotEmpty ||
      (neighborhood ?? '').isNotEmpty ||
      (street ?? '').isNotEmpty ||
      (building ?? '').isNotEmpty ||
      (directions ?? '').isNotEmpty;
}

class NominatimReverseGeocoding {
  NominatimReverseGeocoding({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://nominatim.openstreetmap.org',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: const <String, dynamic>{
                'User-Agent': 'dllni-user-app/1.0',
              },
            ),
          );

  final Dio _dio;

  Future<NominatimAddressFields?> reverse({
    required double latitude,
    required double longitude,
    String acceptLanguage = 'ar,en',
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/reverse',
        queryParameters: <String, dynamic>{
          'format': 'jsonv2',
          'lat': latitude,
          'lon': longitude,
          'addressdetails': 1,
          'accept-language': acceptLanguage,
        },
      );
      final data = response.data;
      if (data == null) return null;
      return parse(data);
    } catch (_) {
      return null;
    }
  }

  static NominatimAddressFields parse(Map<String, dynamic> payload) {
    String? pickFirst(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) continue;
        final normalized = '$value'.trim();
        if (normalized.isNotEmpty) return normalized;
      }
      return null;
    }

    Map<String, dynamic> address = const <String, dynamic>{};
    final rawAddress = payload['address'];
    if (rawAddress is Map) {
      address = rawAddress.map((key, value) => MapEntry('$key', value));
    }

    final city = pickFirst(address, const <String>[
      'city',
      'town',
      'village',
      'municipality',
      'state_district',
      'county',
      'state',
    ]);
    final neighborhood = pickFirst(address, const <String>[
      'suburb',
      'neighbourhood',
      'neighborhood',
      'quarter',
      'city_district',
      'district',
      'residential',
    ]);
    final street = pickFirst(address, const <String>[
      'road',
      'street',
      'pedestrian',
      'footway',
      'path',
    ]);
    final building = pickFirst(address, const <String>[
      'house_number',
      'building',
      'house_name',
      'block',
    ]);
    final displayName = payload['display_name']?.toString().trim();
    final directions = displayName?.isNotEmpty == true
        ? displayName
        : pickFirst(address, const <String>['postcode', 'country']);

    return NominatimAddressFields(
      city: city,
      neighborhood: neighborhood,
      street: street,
      building: building,
      directions: directions,
      displayName: displayName?.isEmpty == true ? null : displayName,
    );
  }
}
