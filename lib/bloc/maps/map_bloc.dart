import 'package:bloc/bloc.dart';
// Services
import 'package:hand_in_need/services/google_places/google_places_service.dart';
import 'package:hand_in_need/services/google_places/autocomplete_result.dart';
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
import 'package:hand_in_need/services/geolocator/geolocator_exceptions.dart';
import 'package:hand_in_need/services/geolocator/geolocator_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/opportunities/opportunity.dart';
// Util
import 'dart:async';

part 'map_events.dart';
part 'map_states.dart';


class MapBloc extends Bloc<MapEvent, MapState> {
  final _opportunityService = OpportunityService();
  final _googlePlacesService = GooglePlacesService();
  final _geolocationService = GeoLocatorService();
  static final defaultBounds = LatLngBounds(
    northeast: const LatLng(0, 0),
    southwest: const LatLng(0, 0),
  );

  StreamSubscription<List<Opportunity>>? opsStream;

  MapBloc() : super(const LoadingState()) {
    opsStream = _opportunityService
        .allOpportunities(defaultBounds)
        .listen((value) => add(UpdateDataEvent(value)));

    on<InitializeEvent>((event, emit) async {
      try {
        final location = await _geolocationService.getCurrentLocation();
        emit(PositionSuccessState(position: location));
      } on GeoLocatorException catch (e) {
        emit(PositionFailState(exception: e));
      }
    });

    on<BoundsUpdateEvent>((event, emit) async {
      final controller = event.controller;
      final bounds = await controller.getVisibleRegion();
      opsStream?.cancel();
      opsStream = _opportunityService
          .allOpportunities(bounds)
          .listen((value) => add(UpdateDataEvent(value)));
    });

    on<UpdateLocationEvent>((event, emit) async {
      emit(const LoadingState());
      final place = await _googlePlacesService.fetchPlace(event.result.placeId);
      emit(PositionSuccessState(position: place.location));
    });

    on<UpdateDataEvent>((event, emit) {
      emit(FetchSuccessMapState(opportunities: event.ops));
    });
  }

  @override
  Future<void> close() {
    opsStream?.cancel();
    return super.close();
  }
}
