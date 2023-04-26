import 'package:hand_in_need/services/geolocator/geolocator_exceptions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GeoLocatorService {
  static final _shared = GeoLocatorService._sharedInstance();
  GeoLocatorService._sharedInstance();
  factory GeoLocatorService() => _shared;

  Future<void> getPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledGeolocatorException();
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedGeolocatorException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedForeverGeolocatorException();
    }
  }

  Future<LatLng> getCurrentLocation() async {
    await getPermission();
    final location = await Geolocator.getCurrentPosition();
    return LatLng(location.latitude, location.longitude);
  }

  double getDistance({ required LatLng start, required LatLng end }) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }
}