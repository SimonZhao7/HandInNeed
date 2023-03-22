part of './map_bloc.dart';

class MapState {
  final bool loading;
  final List<Opportunity> ops;
  const MapState({
    required this.loading,
    this.ops = const [],
  });
}

class LoadingState extends MapState {
  const LoadingState() : super(loading: true);
}

class PositionSuccessState extends MapState {
  final LatLng position;
  const PositionSuccessState({
    required this.position,
  }) : super(loading: true);
}

class PositionFailState extends MapState {
  final GeoLocatorException exception;
  const PositionFailState({
    required this.exception,
  }) : super(loading: false);
}

class FetchSuccessMapState extends MapState {
  const FetchSuccessMapState({required List<Opportunity> opportunities})
      : super(
          loading: false,
          ops: opportunities,
        );
}
