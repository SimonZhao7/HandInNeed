import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';

import 'map_events.dart';
import 'map_states.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final _opportunityService = OpportunityService();

  MapBloc()
      : super(
          FetchSuccessMapState(
            LatLngBounds(
              northeast: const LatLng(0, 0),
              southwest: const LatLng(0, 0),
            ),
          ),
        ) {
    on<BoundsUpdateEvent>((event, emit) async {
      final controller = event.controller;
      final bounds = await controller.getVisibleRegion();
      final ops = await _opportunityService.allOpportunities(bounds).first;
      if (ops.isEmpty) {
        emit(FetchErrorMapState(
          'No nearby opportunities found. Try a different search.',
          state.bounds,
        ));
      }
      emit(FetchSuccessMapState(bounds));
    });
  }
}
