import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapbox_gl/mapbox_gl.dart';

class MapServices {
  static const String accessToken =
      'pk.eyJ1IjoiYWtoaWxsZXZha3VtYXIiLCJhIjoiY2x4MDcwYzZ4MGl2aTJqcmFxbXZzc3lndiJ9.9sxfvrADlA25b1CHX2VuDA';

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}?geometries=geojson&access_token=$accessToken');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> coords = data['routes'][0]['geometry']['coordinates'];
      return coords.map((c) => LatLng(c[1], c[0])).toList();
    }
    return [];
  }

  // Fetches distance between two points
  Future<double?> getDistance(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}?geometries=geojson&access_token=$accessToken');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      double distanceInMeters = data['routes'][0]['distance'];
      return distanceInMeters / 1000; // Convert to KM
    }
    return null;
  }
}
