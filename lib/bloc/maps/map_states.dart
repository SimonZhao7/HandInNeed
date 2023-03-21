// Services
import 'package:hand_in_need/services/geolocator/geolocator_exceptions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState {
  final LatLng position;
  final LatLngBounds bounds;
  final bool loading;

  const MapState({
    this.position = const LatLng(0, 0),
    required this.bounds,
    this.loading = false,
  });
}

class LoadingState extends MapState {
  const LoadingState({required bounds}) : super(bounds: bounds, loading: true);
}

class PositionSuccessState extends MapState {
  const PositionSuccessState({
    required LatLng position,
    required LatLngBounds bounds,
  }) : super(position: position, bounds: bounds, loading: true);
}

class PositionFailState extends MapState {
  final GeoLocatorException exception;
  const PositionFailState({
    required this.exception,
    required LatLngBounds bounds,
  }) : super(bounds: bounds);
}

class FetchSuccessMapState extends MapState {
  const FetchSuccessMapState({
    required LatLngBounds bounds,
    required LatLng position,
  }) : super(bounds: bounds, position: position);
}
