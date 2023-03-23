part of './map_bloc.dart';

class MapState {
  final bool loading;
  final BitmapDescriptor bitmap;
  final List<Opportunity> ops;
  const MapState({
    required this.loading,
    required this.bitmap,
    this.ops = const [],
  });
}

class LoadingState extends MapState {
  const LoadingState({required super.bitmap}) : super(loading: true);
}

class PositionSuccessState extends MapState {
  final LatLng position;
  const PositionSuccessState({
    required super.bitmap,
    required this.position,
  }) : super(loading: true);
}

class PositionFailState extends MapState {
  final GeoLocatorException exception;
  const PositionFailState({
    required super.bitmap,
    required this.exception,
  }) : super(loading: false);
}

class FetchSuccessMapState extends MapState {
  const FetchSuccessMapState({
    required List<Opportunity> opportunities,
    required super.bitmap,
  }) : super(
          loading: false,
          ops: opportunities,
        );
}
