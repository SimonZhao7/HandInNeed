import 'package:flutter/material.dart';
// Firebase
import 'package:hand_in_need/services/cloud_storage/cloud_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Services
import 'package:hand_in_need/services/google_places/google_places_service.dart';
import 'package:hand_in_need/services/deep_links/deep_links_service.dart';
import 'package:hand_in_need/services/opportunities/opportunity.dart';
import 'package:hand_in_need/services/crypto/crypto_service.dart';
import 'package:hand_in_need/services/email/email_service.dart';
import 'package:hand_in_need/services/auth/auth_service.dart';
// Widgets
import 'package:hand_in_need/services/google_places/autocomplete_result.dart';
import 'package:image_picker/image_picker.dart';
// Constants
import 'package:hand_in_need/services/opportunities/opportunity_exceptions.dart';
import 'package:hand_in_need/services/opportunities/fields.dart';
// Util
import 'package:validators/validators.dart';

class OpportunityService {
  static final OpportunityService _shared =
      OpportunityService._sharedInstance();
  OpportunityService._sharedInstance();
  factory OpportunityService() => _shared;

  final _storageService = CloudStorageService();
  final _placesService = GooglePlacesService();
  final _deepLinkService = DeepLinksService();
  final _cryptoService = CryptoService();
  final _emailService = EmailService();
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

    final place = await _placesService.fetchPlace(location);

    final imageUrl = await _storageService.uploadImage(
      selectedPhoto: selectedPhoto,
      path: imagesPath,
    );

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
      placeIdField: place.placeId,
      addressField: place.address,
      phoneNumberField: place.phoneNumber,
      latField: place.location.latitude,
      lngField: place.location.longitude,
      websiteField: place.website,
      nameField: place.name,
    });
    
    await _sendVerificationEmail(
      newEmail: organizationEmail,
      id: ref.id,
    );
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
    await _sendVerificationEmail(
      newEmail: newEmail,
      id: id,
    );
  }

  Future<void> verifyOpportunity(String id) async {
    await db.doc(id).update({
      'verified': true,
    });
  }

  Future<void> _sendVerificationEmail({
    required String newEmail,
    required String id,
  }) async {
    final hash = _cryptoService.hashString(value: newEmail);
    final dynamicLink = await _deepLinkService.createOpportunityVerifyDeepLink(
      id: id,
      hash: hash.toString(),
    );
    await _emailService.sendOpportunityVerificationEmail(
      toEmail: newEmail,
      dynamicLink: dynamicLink,
    );
  }
}
