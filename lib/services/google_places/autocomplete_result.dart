import 'package:hand_in_need/services/opportunities/fields.dart';

class AutocompleteResult {
  final String description;
  final String? placeId;

  AutocompleteResult({
    required this.description,
    required this.placeId,
  });

  factory AutocompleteResult.fromJson(Map<String, dynamic> json) {
    return AutocompleteResult(
      description: json[descriptionField],
      placeId: json['place_id'],
    );
  }
}
