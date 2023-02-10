import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String placeId;
  final String address;
  final String phoneNumber;
  final String website;
  final String name;
  final LatLng location;

  Place({
    required this.placeId,
    required this.address,
    required this.phoneNumber,
    required this.website,
    required this.location,
    required this.name,
  });
}
