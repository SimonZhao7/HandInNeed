import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapState {
  final LatLngBounds bounds;
  const MapState(this.bounds);
}

class FetchSuccessMapState extends MapState {
  const FetchSuccessMapState(super.bounds);
}

class FetchErrorMapState extends MapState {
  final String errorMessage;
  const FetchErrorMapState(this.errorMessage, super.bounds);
}