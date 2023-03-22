part of './map_bloc.dart';

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

class UpdateDataEvent extends MapEvent {
  final List<Opportunity> ops;
  const UpdateDataEvent(this.ops);
}