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
// Extensions
import 'package:hand_in_need/extensions/query_methods.dart';
// Util
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  Stream<List<Opportunity>> allOpportunities(LatLngBounds bound) {
    final fromBound = bound.southwest;
    final toBound = bound.northeast;
    return db
        .where(verifiedField, isEqualTo: true)
        .where(startTimeField, isGreaterThan: Timestamp.now())
        .snapshots()
        .map(
          (s) => s.docs.map(Opportunity.fromFirebase).where((op) {
            final location = op.place.location;
            final lat = location.latitude;
            final lng = location.longitude;
            return fromBound.latitude < lat &&
                lat < toBound.latitude &&
                fromBound.longitude < lng &&
                lng < toBound.longitude;
          }).toList(),
        );
  }

  Stream<List<Opportunity>> yourOpportunities(bool past) => db
      .where(userIdField, isEqualTo: _authService.userDetails.uid)
      .filterTime(past: past, fieldName: endTimeField)
      .snapshots()
      .map((s) => s.docs.map(Opportunity.fromFirebase).toList());

  Stream<List<Opportunity>> manageOpportunities(bool past) => db
      .where(organizationEmailField, isEqualTo: _authService.userDetails.email)
      .filterTime(past: past, fieldName: endTimeField)
      .snapshots()
      .map((s) => s.docs.map(Opportunity.fromFirebase).toList());

  Stream<List<Opportunity>> upcomingOpportunities({required bool past}) => db
      .where(attendeesField, arrayContains: _authService.userDetails.uid)
      .filterTime(past: past, fieldName: startTimeField)
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
    _validateTitle(value: title);
    _validateUrl(value: url);
    _validateOrganizationEmail(value: organizationEmail);
    _validatePhoto(value: selectedPhoto);
    final formattedDates = _validateTimes(
      startDate: startDate,
      startTime: startTime,
      endTime: endTime,
    );
    _validateLocation(value: location);

    final place = await _placesService.fetchPlaceFromAutoComplete(location!);
    final imageUrl = await _storageService.uploadImage(
      selectedPhoto: selectedPhoto!,
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
      startTimeField: formattedDates[startTimeField],
      endTimeField: formattedDates[endTimeField],
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

  Stream<Opportunity> getOpportunityStream(String id) {
    return db
        .where(FieldPath.documentId, isEqualTo: id)
        .snapshots()
        .map((s) => Opportunity.fromFirebase(s.docs[0]));
  }

  Future<void> updateOpportunity({
    required String id,
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
    final opportunity = await _getOpportunity(id);
    final Map<String, Object?> updateMap = {};

    _validateTitle(value: title);
    updateMap[titleField] = title;
    _validateUrl(value: url);
    updateMap[urlField] = url;
    _validateOrganizationEmail(value: organizationEmail);
    updateMap[organizationEmailField] = organizationEmail;
    _validatePhoto(skipNull: true, value: selectedPhoto);
    final formattedDates = _validateTimes(
      opportunity: opportunity,
      startDate: startDate,
      startTime: startTime,
      endTime: endTime,
    );
    updateMap[startDateField] = formattedDates[startDateField];
    updateMap[startTimeField] = formattedDates[startTimeField];
    updateMap[endTimeField] = formattedDates[endTimeField];
    _validateLocation(skipNull: true, value: location);
    if (location != null) {
      final place = await _placesService.fetchPlaceFromAutoComplete(location);
      updateMap[placeIdField] = place.placeId;
      updateMap[addressField] = place.address;
      updateMap[phoneNumberField] = place.phoneNumber;
      updateMap[latField] = place.location.latitude;
      updateMap[lngField] = place.location.longitude;
      updateMap[websiteField] = place.website;
      updateMap[nameField] = place.name;
    }

    if (selectedPhoto != null) {
      final photoURL = await _storageService.uploadImage(
        selectedPhoto: selectedPhoto,
        path: imagesPath,
      );
      updateMap[imageField] = photoURL;
    }

    final oldDifference = opportunity.endTime.difference(opportunity.startTime);
    final newDifference = formattedDates[endTimeField]!.difference(
      formattedDates[startTimeField]!,
    );
    final netDiff = oldDifference.inMinutes / 60 + newDifference.inMinutes / 60;

    await _handleOpportunityTimeUpdate(
        opportunity: opportunity, netDiff: netDiff);
    await db.doc(id).update(updateMap);
  }

  Future<void> deleteOpportunity(String id) async {
    final op = await _getOpportunity(id);
    await _handleOpportunityTimeUpdate(
      opportunity: op,
      netDiff: op.endTime.difference(op.startTime).inMinutes / 60,
    );
    await db.doc(id).delete();
  }

  Future<void> manageJoinStatus({
    required String opportunityId,
    required String userId,
  }) async {
    final attendees = (await _getOpportunity(opportunityId)).attendees;
    if (attendees.contains(userId)) {
      attendees.remove(userId);
    } else {
      attendees.add(userId);
    }
    await db.doc(opportunityId).update({attendeesField: attendees});
  }

  Future<void> transferOwnership({
    required String id,
    required String newEmail,
    required String confirmEmail,
    required String hash,
  }) async {
    final query = await db.where(FieldPath.documentId, isEqualTo: id).get();
    if (query.docs.isEmpty) {
      throw DoesNotExistOpportunityException();
    }

    final opportunity = Opportunity.fromFirebase(query.docs.first);

    if (!_cryptoService.checkHash(
      value: opportunity.organizationEmail,
      hash: hash,
    )) {
      throw EmailMismatchOpportunityException();
    }

    if (!isEmail(newEmail)) {
      throw InvalidOrganizationEmailOpportunityException();
    }

    if (newEmail != confirmEmail) {
      throw EmailsDoNotMatchOpportunityException();
    }

    if (newEmail == opportunity.organizationEmail) {
      throw EmailNotChangedOpportunityException();
    }

    await db.doc(id).update({
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

  Future<void> handleEmailChanges({required String oldEmail}) async {
    final query = await db
        .where(
          organizationEmailField,
          isEqualTo: oldEmail,
        )
        .get();
    for (final doc in query.docs) {
      await doc.reference.update({
        organizationEmailField: _authService.userDetails.email,
      });
    }
  }

  Future<Opportunity> _getOpportunity(String id) async {
    return Opportunity.fromFirebase(
      (await db.where(FieldPath.documentId, isEqualTo: id).get()).docs.first,
    );
  }

  Future<void> _handleOpportunityTimeUpdate({
    required Opportunity opportunity,
    required double netDiff,
  }) async {
    for (String id in opportunity.attendees) {
      final user = await _authService.getUser(id);
      await _authService.updateHoursWorked(
        id: id,
        newHours: user.hoursWorked - netDiff,
      );
    }
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

  void _validateTitle({required String value}) {
    if (value.trim().length < 8) {
      throw TitleTooShortOpportunityException();
    }
  }

  void _validateUrl({required String value}) {
    if (value.trim().isEmpty) {
      throw NoUrlProvidedOpportunityException();
    }

    if (!isURL(value, requireProtocol: true, requireTld: true)) {
      throw InvalidUrlOpportunityException();
    }
  }

  void _validateOrganizationEmail({required String value}) {
    if (value.trim().isEmpty) {
      throw NoOrganizationEmailProvidedOpportunityException();
    }

    if (!isEmail(value)) {
      throw InvalidOrganizationEmailOpportunityException();
    }
  }

  void _validatePhoto({skipNull = false, required XFile? value}) {
    if (value == null && !skipNull) {
      throw NoPhotoProvidedOpportunityException();
    }
  }

  Map<String, DateTime> _validateTimes({
    Opportunity? opportunity,
    required DateTime? startDate,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
  }) {
    if (opportunity == null) {
      if (startDate == null) {
        throw NoStartDateProvidedOpportunityException();
      }

      if (startTime == null) {
        throw NoStartTimeProvidedOpportunityException();
      }

      if (endTime == null) {
        throw NoEndTimeProvidedOpportunityExcpeption();
      }
    } else {
      startDate = startDate ?? opportunity.startDate;
      startTime = startTime ?? TimeOfDay.fromDateTime(opportunity.startDate);
      endTime = endTime ?? TimeOfDay.fromDateTime(opportunity.endTime);
    }
    final now = DateTime.now();
    final currDate = DateTime(now.year, now.month, now.day);
    final startTimeHours = startTime.hour + startTime.minute / 60;
    final endTimeHours = endTime.hour + endTime.minute / 60;
    final nowHours = now.hour + now.minute / 60;

    if (startDate == currDate && startTimeHours < nowHours) {
      throw InvalidStartTimeOpportunityException();
    }

    if (endTimeHours < startTimeHours) {
      throw OutOfOrderTimesOpportunityException();
    }

    return {
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
    };
  }

  void _validateLocation({
    skipNull = false,
    required AutocompleteResult? value,
  }) {
    if (value == null && !skipNull) {
      throw NoLocationProvidedOpportunityExcpetion();
    }
  }
}
