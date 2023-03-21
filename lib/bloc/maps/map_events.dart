import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapEvent {
  const MapEvent();
}

class BoundsUpdateEvent extends MapEvent {
  final GoogleMapController controller;
  const BoundsUpdateEvent(this.controller) : super();
}
