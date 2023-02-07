import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'autocomplete_result.dart';
// Widgets
import 'package:hand_in_need/widgets/input.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';
// Util
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressSearch extends StatefulWidget {
  const AddressSearch({super.key});

  @override
  State<AddressSearch> createState() => _AddressSearchState();
}

class _AddressSearchState extends State<AddressSearch> {
  List<AutocompleteResult> results = [];
  late TextEditingController _searchInput;

  @override
  void initState() {
    _searchInput = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchInput.dispose();
    super.dispose();
  }

  void _updateSearchResults(String text) async {
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': text,
        'radius': '50000',
        'key': dotenv.env['MAPS_API_KEY'],
      },
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final parsedData = jsonDecode(response.body);
      final predictions = parsedData['predictions'] as List<dynamic>;
      final newResults = predictions
          .map((prediction) => AutocompleteResult.fromJson(prediction))
          .toList();
      setState(() {
        results = newResults;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Input(
          controller: _searchInput,
          borderWidth: 0,
          fillColor: white,
          onChanged: _updateSearchResults,
          hint: 'Enter an address...',
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          if (results.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.center,
              child: Text(
                'No results...',
                style: Theme.of(context).textTheme.headline3,
              ),
            )
          else
            ...results.map(
              (result) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).pop(result);
                  },
                  title: Text(result.description),
                );
              },
            ).toList()
        ],
      ),
    );
  }
}
