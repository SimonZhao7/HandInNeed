import 'package:google_maps_flutter/google_maps_flutter.dart';
// Services
import 'package:hand_in_need/services/google_places/autocomplete_result.dart';

abstract class MapEvent {
  const MapEvent();
}

class InitializeEvent extends MapEvent {
  const InitializeEvent();
}

class BoundsUpdateEvent extends MapEvent {
  final GoogleMapController controller;
  const BoundsUpdateEvent(this.controller);
}

class UpdateLocationEvent extends MapEvent {
  final AutocompleteResult result;
  const UpdateLocationEvent(this.result);
}