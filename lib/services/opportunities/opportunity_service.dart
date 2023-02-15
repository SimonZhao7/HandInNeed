import 'package:crypto/crypto.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
  final _authService = AuthService();

  final db = FirebaseFirestore.instance.collection(collectionName);

  Stream<List<Opportunity>> allOpportunities() =>
      db.snapshots().map((s) => s.docs.map(Opportunity.fromFirebase).toList());

  Stream<List<Opportunity>> yourOpportunities() => db
      .where(userIdField, isEqualTo: _authService.userDetails.uid)
      .snapshots()
      .map((s) => s.docs.map(Opportunity.fromFirebase).toList());

  Stream<List<Opportunity>> manageOpportunities() => db
      .where(organizationEmailField, isEqualTo: _authService.userDetails.email)
      .snapshots()
      .map((s) => s.docs.map(Opportunity.fromFirebase).toList());

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
      throw NoOrganizationEmailProvidedOpportunityException();
    }

    if (!isEmail(organizationEmail)) {
      throw InvalidOrganizationEmailOpportunityException();
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

        final ref = await db.add({
          userIdField: _authService.userDetails.uid,
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
        await sendVerificationEmail(organizationEmail, ref.id);
      }
    } catch (e) {
      throw LocationNotFoundOpportunityException();
    }
  }

  Future<void> transferOwnership({
    required String id,
    required String newEmail,
    required String confirmEmail,
  }) async {
    final doc = db.doc(id);
    final data = (await doc.get()).data()!;

    if (!isEmail(newEmail)) {
      throw InvalidOrganizationEmailOpportunityException();
    }

    if (newEmail != confirmEmail) {
      throw EmailsDoNotMatchOpportunityException();
    }

    if (newEmail == data[organizationEmailField]) {
      throw EmailNotChangedOpportunityException();
    }

    await doc.update({
      organizationEmailField: newEmail,
    });
    await sendVerificationEmail(newEmail, id);
  }

  Future<void> verifyOpportunity(String id) async {
    await db.doc(id).update({
      'verified': true,
    });
  }

  Future<void> sendVerificationEmail(String newEmail, String id) async {
    final hash = _hashEmail(newEmail);
    final dynamicLink = await _getDynamicLink(id, hash.toString());
    await _sendVerificationEmail(newEmail, dynamicLink);
  }

  Digest _hashEmail(String organizationEmail) {
    final encodedEmail = utf8.encode(organizationEmail);
    final hash = md5.convert(encodedEmail);
    return hash;
  }

  Future<Uri> _getDynamicLink(String id, String hash) async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(
        'https://handinneed.page.link/opportunities/change-email/$id/$hash',
      ),
      uriPrefix: 'https://handinneed.page.link',
      androidParameters: const AndroidParameters(
        packageName: "com.example.hand_in_need",
      ),
    );

    final dynamicLink = await FirebaseDynamicLinksPlatform.instance
        .buildLink(dynamicLinkParams);
    return dynamicLink;
  }

  Future<void> _sendVerificationEmail(String toEmail, Uri dynamicLink) async {
    final sendEmailUrl = Uri.https(
      'api.sendgrid.com',
      '/v3/mail/send',
    );

    await http.post(
      sendEmailUrl,
      headers: {
        'Authorization': 'Bearer ${dotenv.env['SENDGRID_API_KEY']}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'personalizations': [
          {
            'to': [
              {
                'email': toEmail,
              }
            ],
          }
        ],
        'from': {
          'email': 'handinneedgsdc@gmail.com',
          'name': 'The HandInNeed Team',
        },
        'subject': 'Volunteer Opportunity Hosting',
        'content': [
          {
            'type': 'text/html',
            'value': """
              <p>Hello!<p>
              <p>A user of our volunteer opportunity sharing app has decided to post details of your upcoming opportunity.</p>
              <p>In order to verify and manage attendees from our app, please install and sign up with this email. 
              Then, verify this opportuity by going to the "Your Jobs" section and the "Your Hostings" tab on the top. 
              Find the correct opportunity and press verify to complete the verification and manage attendees.</p>
              <p>If you prefer to use a different email for the account, please provide your desired email <a href="$dynamicLink">here</a></p>
              <p>If you didn't organize an event, please disregard this email</p>
              <br />
              <br />
              <p>Happy Volunteering,</p>
              <b>- The HandInNeedTeam</b>
            """,
          }
        ],
      }),
    );
  }
}
