import 'package:flutter/material.dart';
// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
// Widgets
import '../widgets/autocomplete/autocomplete_result.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/input.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/button.dart';
// Constants
import 'package:hand_in_need/constants/routes.dart';
// Util
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:validators/validators.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

class AddOpportunity extends StatefulWidget {
  const AddOpportunity({super.key});

  @override
  State<AddOpportunity> createState() => _AddOpportunityState();
}

class _AddOpportunityState extends State<AddOpportunity> {
  final AuthService _authService = AuthService();
  late TextEditingController _title;
  late TextEditingController _description;
  late TextEditingController _url;
  late TextEditingController _organizationEmail;
  late TextEditingController _address;
  XFile? selectedPhoto;
  DateTime? startDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  AutocompleteResult? location;

  @override
  void initState() {
    _title = TextEditingController();
    _description = TextEditingController();
    _url = TextEditingController();
    _organizationEmail = TextEditingController();
    _address = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _url.dispose();
    _organizationEmail.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd();
    final label = Theme.of(context).textTheme.labelMedium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Opportunity'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title', style: label),
              Input(
                controller: _title,
              ),
              Text('Description', style: label),
              Input(
                controller: _description,
                maxLines: 5,
              ),
              Text('Website', style: label),
              Input(controller: _url),
              Text('Organization Email', style: label),
              Input(controller: _organizationEmail),
              const SizedBox(height: 10),
              Text('Image', style: label),
              Button(
                onPressed: () async {
                  final imagePicker = ImagePicker();
                  final XFile? photo = await imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (photo == null) return;
                  setState(() {
                    selectedPhoto = photo;
                  });
                },
                label: 'Choose a photo',
              ),
              const SizedBox(height: 10),
              Text(
                'Start Date',
                style: label,
              ),
              Button(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(
                      const Duration(
                        days: 365,
                      ),
                    ),
                    initialEntryMode: DatePickerEntryMode.input,
                  );
                  setState(() {
                    startDate = selectedDate;
                  });
                },
                label: startDate != null
                    ? dateFormat.format(startDate!)
                    : 'Select a start date',
              ),
              const SizedBox(height: 10),
              Text('Start Time', style: label),
              Button(
                onPressed: () async {
                  final selectedTime = await _showTimeInput();
                  setState(() {
                    startTime = selectedTime;
                  });
                },
                label: startTime != null
                    ? startTime!.format(context)
                    : 'Select a start time',
              ),
              const SizedBox(height: 10),
              Text('End Time', style: label),
              Button(
                onPressed: () async {
                  final selectedTime = await _showTimeInput();
                  setState(() {
                    endTime = selectedTime;
                  });
                },
                label: endTime != null
                    ? endTime!.format(context)
                    : 'Select an end time',
              ),
              const SizedBox(height: 10),
              Text('Address', style: label),
              Input(
                readOnly: true,
                controller: _address,
                onTap: () async {
                  final address = await Navigator.of(context)
                      .pushNamed(inputAddressRoute) as AutocompleteResult?;
                  if (address == null) return;
                  _address.text = address.description;
                  setState(() {
                    location = address;
                  });
                },
              ),
              const SizedBox(height: 10),
              Button(onPressed: _handleSubmit, label: 'Submit')
            ],
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    final title = _title.text;
    final description = _description.text;
    final url = _url.text;
    final organizationEmail = _organizationEmail.text;

    if (title.trim().length < 8) {
      showErrorSnackbar(context, 'Provided title is too short');
      return;
    }

    if (url.trim().isEmpty) {
      showErrorSnackbar(context, 'No url provided');
      return;
    }

    if (!isURL(url, requireProtocol: true, requireTld: true)) {
      showErrorSnackbar(
        context,
        'Please enter a valid url',
      );
      return;
    }

    if (organizationEmail.trim().isEmpty) {
      showErrorSnackbar(context, 'No organization email provided');
      return;
    }

    if (!isEmail(organizationEmail)) {
      showErrorSnackbar(context, 'Invalid email');
      return;
    }

    if (selectedPhoto == null) {
      showErrorSnackbar(context, 'No photo provided');
      return;
    }

    if (startDate == null) {
      showErrorSnackbar(context, 'No start date provided');
      return;
    }

    if (startTime == null) {
      showErrorSnackbar(context, 'No start time provided');
      return;
    }

    if (endTime == null) {
      showErrorSnackbar(context, 'No end time provided');
      return;
    }

    if (endTime!.hour + endTime!.minute / 60 <
        startTime!.hour + startTime!.minute / 60) {
      showErrorSnackbar(
        context,
        'The end time must be later than the start time',
      );
      return;
    }

    if (location == null) {
      showErrorSnackbar(context, 'No location provided');
      return;
    }

    try {
      final user = (await _authService.currentUser())!;
      final db = FirebaseFirestore.instance.collection('opportunities');
      final storage = FirebaseStorage.instance.ref('/opportunity_photos');
      final placesUrl = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': location!.placeId ?? '',
          'fields': [
            'place_id',
            'formatted_address',
            'formatted_phone_number',
            'geometry',
            'name',
            'website',
          ].join(','),
          'key': dotenv.env['MAPS_API_KEY'],
        },
      );

      final response = await http.get(placesUrl);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final result = body['result'];

        final file = File(selectedPhoto!.path);
        final storageRef =
            storage.child('${const Uuid().v4()}-${selectedPhoto!.name}');
        await storageRef.putFile(file);
        final imageUrl = await storageRef.getDownloadURL();

        await db.add({
          'user': user.id,
          'title': title,
          'description': description,
          'url': url,
          'organization_email': organizationEmail,
          'attendees': [],
          'verified': false,
          'start_date': startDate,
          'start_time': startDate!.add(
            Duration(
              hours: startTime!.hour,
              minutes: startTime!.minute,
            ),
          ),
          'end_time': startDate!.add(
            Duration(
              hours: endTime!.hour,
              minutes: endTime!.minute,
            ),
          ),
          'image': imageUrl,
          'created_at': FieldValue.serverTimestamp(),
          // Place
          'place_id': result['place_id'],
          'address': result['formatted_address'],
          'phone_number': result['formatted_phone_number'],
          'lat': result['geometry']['location']['lat'],
          'lng': result['geometry']['location']['lng'],
          'place_website': result['website'],
        });
        Navigator.of(context).pop();
      }
    } catch (e) {
      showErrorSnackbar(
        context,
        'Location can not be found in this address. Please enter a different location.',
      );
    }
  }

  Future<TimeOfDay?> _showTimeInput() {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
  }
}
