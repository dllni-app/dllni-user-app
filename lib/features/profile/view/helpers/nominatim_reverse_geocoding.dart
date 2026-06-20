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
        options: Options(
          headers: {
            'Accept-Language': acceptLanguage,
          },
        ),
        queryParameters: <String, dynamic>{
          'format': 'jsonv2',
          'lat': latitude,
          'lon': longitude,
          'zoom': 18,
          'addressdetails': 1,
          'layer': 'address',
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
    String? normalizeValue(dynamic value) {
      if (value == null) return null;
      final normalized = '$value'.trim();
      return normalized.isEmpty ? null : normalized;
    }

    String? pickFirst(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        final normalized = normalizeValue(map[key]);
        if (normalized != null) return normalized;
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
      'neighbourhood',
      'neighborhood',
      'suburb',
      'quarter',
      'city_district',
      'district',
      'residential',
      'locality',
    ]);
    final street = pickFirst(address, const <String>[
      'road',
      'street',
      'pedestrian',
      'footway',
      'path',
      'residential',
    ]);
    final building = pickFirst(address, const <String>[
      'building',
      'house_name',
      'house_number',
      'amenity',
      'shop',
      'office',
      'tourism',
      'block',
    ]) ?? normalizeValue(payload['name']);
    final displayName = normalizeValue(payload['display_name']);
    final directions = displayName ?? pickFirst(address, const <String>[
      'postcode',
      'country',
    ]);

    return NominatimAddressFields(
      city: city,
      neighborhood: neighborhood,
      street: street,
      building: building,
      directions: directions,
      displayName: displayName,
    );
  }
}
