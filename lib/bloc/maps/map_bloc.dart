import 'package:bloc/bloc.dart';
import 'map_events.dart';
import 'map_states.dart';
// Services
import 'package:hand_in_need/services/geolocator/geolocator_exceptions.dart';
import 'package:hand_in_need/services/google_places/google_places_service.dart';
import 'package:hand_in_need/services/geolocator/geolocator_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final _googlePlacesService = GooglePlacesService();
  final _geolocationService = GeoLocatorService();
  static final defaultBounds = LatLngBounds(
    northeast: const LatLng(0, 0),
    southwest: const LatLng(0, 0),
  );

  MapBloc()
      : super(
          LoadingState(bounds: defaultBounds),
        ) {
    on<InitializeEvent>((event, emit) async {
      emit(LoadingState(bounds: state.bounds));
      try {
        final location = await _geolocationService.getCurrentLocation();
        emit(PositionSuccessState(position: location, bounds: state.bounds));
      } on GeoLocatorException catch (e) {
        emit(PositionFailState(exception: e, bounds: defaultBounds));
      }
    });

    on<BoundsUpdateEvent>((event, emit) async {
      final controller = event.controller;
      final bounds = await controller.getVisibleRegion();
      emit(FetchSuccessMapState(bounds: bounds, position: state.position));
    });

    on<UpdateLocationEvent>((event, emit) async {
      emit(LoadingState(bounds: state.bounds));
      final place = await _googlePlacesService.fetchPlace(event.result.placeId);
      emit(
          PositionSuccessState(position: place.location, bounds: state.bounds));
    });
  }
}
