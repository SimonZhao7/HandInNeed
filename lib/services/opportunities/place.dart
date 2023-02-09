import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hand_in_need/services/opportunities/fields.dart';

class Place {
  final String placeId;
  final String address;
  final String phoneNumber;
  final String website;
  final LatLng location;

  Place({
    required this.placeId,
    required this.address,
    required this.phoneNumber,
    required this.website,
    required this.location,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json[placeIdField],
      address: json[addressField],
      phoneNumber: json[phoneNumberField],
      website: json[websiteField],
      location: LatLng(
        json[latField],
        json[lngField],
      ),
    );
  }
}
