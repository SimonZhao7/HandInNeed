// Services
import 'package:hand_in_need/services/google_places/google_places_exceptions.dart';
import 'package:hand_in_need/services/google_places/autocomplete_result.dart';
import 'package:hand_in_need/services/google_places/fields.dart';
import 'package:hand_in_need/services/google_places/place.dart';
// Util
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GooglePlacesService {
  static final _shared = GooglePlacesService._sharedInstance();
  GooglePlacesService._sharedInstance();
  factory GooglePlacesService() => _shared;

  Future<List<AutocompleteResult>> autocompleteQuery({
    required String query,
  }) async {
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': query,
        'radius': '50000',
        'key': dotenv.env['MAPS_API_KEY'],
      },
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      final predictions = parsedData[predictionsField] as List<dynamic>;
      return predictions
          .map((prediction) => AutocompleteResult.fromJson(prediction))
          .toList();
    }
    throw UnableToFetchGooglePlacesException();
  }

  Future<Place> fetchPlace(AutocompleteResult location) async {
    final placesUrl = Uri.https(
      domainName,
      pathName,
      {
        placeIdField: location.placeId ?? '',
        fields: [
          placeIdField,
          formattedAddressField,
          formattedPhoneNumberField,
          geometryField,
          placeNameField,
          googleWebsiteField,
        ].join(','),
        key: dotenv.env['MAPS_API_KEY'],
      },
    );

    final response = await http.get(placesUrl);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Place.fromJSON(body[resultField]);
    }
    throw UnableToFetchGooglePlacesException();
  }
}
