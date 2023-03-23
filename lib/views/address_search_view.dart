import 'package:flutter/material.dart';
// Widgets
import 'package:hand_in_need/widgets/error_snackbar.dart';
// Services
import 'package:hand_in_need/services/google_places/google_places_exceptions.dart';
import 'package:hand_in_need/services/google_places/google_places_service.dart';
import '../services/google_places/autocomplete_result.dart';
// Widgets
import 'package:hand_in_need/widgets/input.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';

class AddressSearchView extends StatefulWidget {
  const AddressSearchView({super.key});

  @override
  State<AddressSearchView> createState() => _AddressSearchViewState();
}

class _AddressSearchViewState extends State<AddressSearchView> {
  List<AutocompleteResult> results = [];
  late TextEditingController _searchInput;
  final _placesService = GooglePlacesService();

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
    try {
      final newResults = await _placesService.autocompleteQuery(
        query: text,
      );
      setState(() {
        results = newResults;
      });
    } catch (e) {
      if (e is UnableToFetchGooglePlacesException) {
        showErrorSnackbar(
          context,
          'Unable to fetch location data',
        );
      } else {
        showErrorSnackbar(
          context,
          'Something went wrong',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Input(
          controller: _searchInput,
          borderWidth: 0,
          fillColor: secondary,
          textColor: white,
          hintColor: white,
          cursorColor: white,
          onChanged: _updateSearchResults,
          autofocus: true,
          hint: 'Enter an address...',
          innerPadding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 15,
          ),
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
