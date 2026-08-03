// Network test: RoutingService against a mocked OSRM HTTP client.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:iloilo_travel_buddy/data/routing_service.dart';
import 'package:latlong2/latlong.dart';

const _from = LatLng(10.70, 122.56);
const _to = LatLng(10.72, 122.55);

String _osrmBody({bool empty = false}) => json.encode({
      'code': 'Ok',
      'routes': empty
          ? []
          : [
              {
                'distance': 4200.0,
                'duration': 720.0,
                'geometry': {
                  'coordinates': [
                    [122.56, 10.70],
                    [122.555, 10.71],
                    [122.55, 10.72],
                  ],
                },
              }
            ],
    });

void main() {
  test('osrmUrl builds a lon,lat;lon,lat driving request', () {
    final url = RoutingService.osrmUrl(_from, _to).toString();
    expect(url, contains('/route/v1/driving/'));
    expect(url, contains('122.56,10.7;122.55,10.72'));
    expect(url, contains('geometries=geojson'));
  });

  test('parse converts geojson [lon,lat] to LatLng and scales units', () {
    final route = RoutingService.parse(_osrmBody());
    expect(route, isNotNull);
    expect(route!.points.first, const LatLng(10.70, 122.56));
    expect(route.km, closeTo(4.2, 0.001));
    expect(route.minutes, closeTo(12, 0.001));
  });

  test('fetch returns a route on 200', () async {
    final client = MockClient((req) async => http.Response(_osrmBody(), 200));
    final route = await RoutingService(client: client).fetch(_from, _to);
    expect(route, isNotNull);
    expect(route!.points, hasLength(3));
  });

  test('fetch returns null on non-200', () async {
    final client = MockClient((req) async => http.Response('nope', 500));
    final route = await RoutingService(client: client).fetch(_from, _to);
    expect(route, isNull);
  });

  test('fetch returns null on a network exception', () async {
    final client = MockClient((req) async => throw http.ClientException('down'));
    final route = await RoutingService(client: client).fetch(_from, _to);
    expect(route, isNull);
  });

  test('parse returns null when there are no routes', () {
    expect(RoutingService.parse(_osrmBody(empty: true)), isNull);
    expect(RoutingService.parse('garbage'), isNull);
  });
}
