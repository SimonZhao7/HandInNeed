class AutocompleteResult {
  final String description;
  final String? placeId;

  AutocompleteResult({
    required this.description,
    required this.placeId,
  });

  factory AutocompleteResult.fromJson(Map<String, dynamic> json) {
    return AutocompleteResult(
      description: json['description'],
      placeId: json['place_id'],
    );
  }
}
