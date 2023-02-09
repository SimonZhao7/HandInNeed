import 'package:flutter/material.dart';
// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Services
import 'package:hand_in_need/services/opportunities/opportunity.dart';
import 'package:hand_in_need/services/auth/auth_service.dart';
// Widgets
import 'package:hand_in_need/widgets/autocomplete/autocomplete_result.dart';
import 'package:image_picker/image_picker.dart';
// Constants
import 'package:hand_in_need/services/opportunities/opportunity_exceptions.dart';
import 'package:hand_in_need/services/opportunities/fields.dart';
// Util
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:validators/validators.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:io';


class OpportunityService {
  static final OpportunityService _shared =
      OpportunityService._sharedInstance();
  OpportunityService._sharedInstance();
  factory OpportunityService() => _shared;

  final db = FirebaseFirestore.instance.collection(collectionName);

  Stream<List<Opportunity>> allOpportunities() => db.snapshots().map(
        (s) => s.docs
            .map(
              Opportunity.fromFirebase,
            )
            .toList(),
      );

Future<void> addOpportunity({
    required String title,
    required String description,
    required String url,
    required String organizationEmail,
    required XFile? selectedPhoto,
    required DateTime? startDate,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required AutocompleteResult? location,
  }) async {
    if (title.trim().length < 8) {
      throw TitleTooShortOpportunityException();
    }

    if (url.trim().isEmpty) {
      throw NoUrlProvidedOpportunityException();
    }

    if (!isURL(url, requireProtocol: true, requireTld: true)) {
      throw InvalidUrlOpportunityException();
    }

    if (organizationEmail.trim().isEmpty) {
      throw NoOrganizationEmailProvidedOpportunityExcpetion();
    }

    if (!isEmail(organizationEmail)) {
      throw InvalidOrganizationEmailOpportunityExcpetion();
    }

    if (selectedPhoto == null) {
      throw NoPhotoProvidedOpportunityException();
    }

    if (startDate == null) {
      throw NoStartDateProvidedOpportunityException();
    }

    if (startTime == null) {
      throw NoStartTimeProvidedOpportunityException();
    }

    if (endTime == null) {
      throw NoEndTimeProvidedOpportunityExcpeption();
    }

    if (endTime.hour + endTime.minute / 60 <
        startTime.hour + startTime.minute / 60) {
      throw OutOfOrderTimesOpportunityException();
    }

    if (location == null) {
      throw NoLocationProvidedOpportunityExcpetion();
    }

    try {
      final user = (await AuthService().currentUser())!;
      final storage = FirebaseStorage.instance.ref(imagesPath);
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
        final result = body[resultField];

        final file = File(selectedPhoto.path);
        final storageRef =
            storage.child('${const Uuid().v4()}-${selectedPhoto.name}');
        await storageRef.putFile(file);
        final imageUrl = await storageRef.getDownloadURL();

        await db.add({
          userIdField: user.id,
          titleField: title,
          descriptionField: description,
          urlField: url,
          organizationEmailField: organizationEmail,
          attendeesField: [],
          verifiedField: false,
          startDateField: startDate,
          startTimeField: startDate.add(
            Duration(
              hours: startTime.hour,
              minutes: startTime.minute,
            ),
          ),
          endTimeField: startDate.add(
            Duration(
              hours: endTime.hour,
              minutes: endTime.minute,
            ),
          ),
          imageField: imageUrl,
          createdAtField: FieldValue.serverTimestamp(),
          // Place
          placeIdField: result[placeIdField],
          addressField: result[formattedAddressField],
          phoneNumberField: result[formattedPhoneNumberField],
          latField: result[geometryField][locationField][latField],
          lngField: result[geometryField][locationField][lngField],
          websiteField: result[googleWebsiteField],
          placeNameField: result[placeNameField],
        });
      }
    } catch (e) {
      throw LocationNotFoundOpportunityException();
    }
  }
}
