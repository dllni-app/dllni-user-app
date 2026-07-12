import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

/// Fetches road-following routes from the public OSRM service (OpenStreetMap data).
class OsrmRouteService {
  OsrmRouteService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://router.project-osrm.org',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: const <String, dynamic>{
                  'User-Agent': 'dllni-user-app/1.0',
                },
              ),
            );

  final Dio _dio;

  /// Returns road geometry between [waypoints], or `null` on failure.
  Future<List<LatLng>?> fetchDrivingRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;

    final coordinates = waypoints
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/route/v1/driving/$coordinates',
        queryParameters: const <String, dynamic>{
          'overview': 'full',
          'geometries': 'geojson',
          'steps': 'false',
        },
      );

      final data = response.data;
      final routes = data?['routes'];
      if (routes is! List || routes.isEmpty) return null;

      final geometry = routes.first['geometry'];
      if (geometry is! Map<String, dynamic>) return null;

      final rawCoords = geometry['coordinates'];
      if (rawCoords is! List || rawCoords.length < 2) return null;

      return rawCoords
          .whereType<List>()
          .map((coord) {
            if (coord.length < 2) return null;
            final lon = coord[0];
            final lat = coord[1];
            if (lon is! num || lat is! num) return null;
            return LatLng(lat.toDouble(), lon.toDouble());
          })
          .whereType<LatLng>()
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }
}

/// Uses backend-provided geometry when dense enough; otherwise fetches OSRM roads.
Future<List<LatLng>> resolveRoadRoutePoints({
  required List<LatLng> apiRoutePoints,
  required List<LatLng> fallbackWaypoints,
  OsrmRouteService? osrm,
}) async {
  if (apiRoutePoints.length >= 8) return apiRoutePoints;

  final service = osrm ?? OsrmRouteService();
  final osrmRoute = await service.fetchDrivingRoute(
    fallbackWaypoints.length >= 2 ? fallbackWaypoints : apiRoutePoints,
  );
  if (osrmRoute != null && osrmRoute.length >= 2) return osrmRoute;

  if (apiRoutePoints.length >= 2) return apiRoutePoints;

  if (fallbackWaypoints.length >= 2) return fallbackWaypoints;

  return const <LatLng>[];
}
