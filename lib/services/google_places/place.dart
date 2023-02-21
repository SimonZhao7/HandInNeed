import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hand_in_need/services/google_places/fields.dart';

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

  factory Place.fromJSON(Map<String, dynamic> data) {
    return Place(
      placeId: data[placeIdField],
      address: data[formattedAddressField],
      phoneNumber: data[formattedPhoneNumberField],
      website: data[googleWebsiteField],
      name: data[placeNameField],
      location: LatLng(
        data[geometryField][locationField][latField],
        data[geometryField][locationField][lngField],
      ),
    );
  }

  factory Place.fromFirebaseMap(Map<String, dynamic> data) {
    return Place(
      placeId: data[placeIdField],
      address: data[addressField],
      phoneNumber: data[phoneNumberField],
      website: data[websiteField],
      name: data[placeNameField],
      location: LatLng(
        data[latField],
        data[lngField],
      ),
    );
  }
}
