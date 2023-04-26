import 'dart:async';
// Firebase
import 'package:hand_in_need/services/geolocator/geolocator_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Services
import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_exceptions.dart';
import 'package:hand_in_need/services/notifications/notification_service.dart';
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
import 'package:hand_in_need/services/opportunity_signups/fields.dart';
import 'package:hand_in_need/services/crypto/crypto_service.dart';
import 'package:hand_in_need/services/auth/auth_service.dart';
import 'opportunity_signup.dart';
// Util
import 'package:validators/validators.dart';

class OpportunitiesSignupsService {
  static final _shared = OpportunitiesSignupsService._sharedInstance();
  OpportunitiesSignupsService._sharedInstance();
  factory OpportunitiesSignupsService() => _shared;

  final db = FirebaseFirestore.instance.collection('opportunity_signups');
  final _opportunityService = OpportunityService();
  final _notificationService = NotificationService();
  final _geoService = GeoLocatorService();
  final _cryptoService = CryptoService();
  final _authService = AuthService();

  Future<OpportunitySignup> getSignup(String id) async =>
      OpportunitySignup.fromFirebase(
        (await db.where(FieldPath.documentId, isEqualTo: id).get()).docs[0],
      );

  Stream<OpportunitySignup?> getExistingSignups() => db
      .where(userIdField, isEqualTo: _authService.userDetails.uid)
      .snapshots()
      .map(
        (s) => s.docs.isEmpty
            ? null
            : OpportunitySignup.fromFirebase(
                s.docs[0],
              ),
      );

  Future<void> createSignup({
    required String password,
    required String confirmPassword,
    required String opportunityId,
  }) async {
    if (password.trim().length < 8) {
      throw PasswordTooShortOpportunitySignupsException();
    }
    if (password != confirmPassword) {
      throw PasswordsDoNotMatchOpportunitySignupsException();
    }
    final hashedPassword = _cryptoService.hashString(value: password);
    await db.add({
      opportunityIdField: opportunityId,
      userIdField: _authService.userDetails.uid,
      passwordField: hashedPassword.toString(),
      verifiedEmailField: null,
    });
  }

  Future<void> deleteSignup({
    required String id,
    required String password,
  }) async {
    final q = await db
        .where(FieldPath.documentId, isEqualTo: id)
        .snapshots()
        .map((s) => s.docs.map(OpportunitySignup.fromFirebase).toList())
        .first;
    if (q.isEmpty) throw DoesNotExistOpportunitySignupsException();
    final signUp = q[0];
    if (!_cryptoService.checkHash(value: password, hash: signUp.password)) {
      throw IncorrectPasswordOpportunitySignupsException();
    }
    await db.doc(id).delete();
  }

  Future<void> sendSignupNotification({
    required OpportunitySignup signup,
    required String email,
  }) async {
    final op = await _opportunityService
        .getOpportunityStream(signup.opportunityId)
        .first;

    if (!isEmail(email)) throw InvalidEmailSignupsException();
    final user = await _authService.getUserFromEmail(email);
    if (!op.attendees.contains(user.id)) {
      throw NotSignedUpForEventSignupsException();
    }
    await _notificationService.sendMessageToUser(
      userId: user.id,
      signupId: signup.id,
    );
  }

  Future<void> verifySignup({
    required String id,
    required LatLng location,
  }) async {
    final user = await _authService.currentUser();
    final signup = await getSignup(id);
    final opportuinty = await _opportunityService
        .getOpportunityStream(signup.opportunityId)
        .first;
    final dist = _geoService.getDistance(
      start: opportuinty.place.location,
      end: location,
    );

    if (dist > 10) {
      throw DistanceTooFarSignupsException();
    }

    await db.doc(id).update({
      verifiedEmailField: user.email,
    });
  }

  Future<void> updateAttendanceStatus({
    required String id,
    required String? enteredEmail,
  }) async {
    final signup = await getSignup(id);

    await db.doc(id).update({
      verifiedEmailField: null,
    });

    if (enteredEmail == null || enteredEmail != signup.verifiedEmail) {
      throw AccountMismatchSignupsException();
    }

    final user = await _authService.getUserFromEmail(signup.verifiedEmail!);
    final op = await _opportunityService
        .getOpportunityStream(signup.opportunityId)
        .first;

    if (user.attended.contains(op.id)) {
      throw AlreadyAttendedSignupsException();
    }

    await _authService.manageAttendedStatus(
      opportunityId: op.id,
      difference: op.endTime.difference(op.startTime),
      userId: user.id,
    );
  }

  Stream<OpportunitySignup> getSignupStream(String id) => db
      .where(FieldPath.documentId, isEqualTo: id)
      .snapshots()
      .map((s) => OpportunitySignup.fromFirebase(s.docs[0]));
}
