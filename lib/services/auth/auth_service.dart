import 'dart:async';
// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Auth
import 'package:hand_in_need/services/cloud_storage/cloud_storage_service.dart';
import 'package:hand_in_need/services/auth/auth_constants.dart';
import 'package:hand_in_need/services/auth/auth_user.dart';
// Util
import 'package:share_plus/share_plus.dart';
// Exceptions
import 'auth_exceptions.dart';

class AuthService {
  static final AuthService _shared = AuthService.instance();
  AuthService.instance();
  factory AuthService() => _shared;

  final db = FirebaseFirestore.instance.collection(userCollectionName);
  final _storageService = CloudStorageService();

  User get userDetails => FirebaseAuth.instance.currentUser!;

  Future<AuthUser> currentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final query =
          await db.where(FieldPath.documentId, isEqualTo: user.uid).get();

      final data = query.docs[0];
      return AuthUser.fromFirebase(data);
    } catch (_) {
      throw NotSignedInAuthException();
    }
  }

  Future<String> sendPhoneVerification({
    required String phoneNumber,
  }) async {
    Completer<String> result = Completer();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+1$phoneNumber',
      verificationCompleted: (
        PhoneAuthCredential credential,
      ) {
        result.complete(credential.verificationId);
      },
      verificationFailed: (e) {
        if (e.code == 'invalid-phone-number') {
          result.completeError(InvalidPhoneNumberAuthException());
        } else if (e.code == 'too-many-requests') {
          result.completeError(TooManyRequestsAuthException());
        } else {
          result.completeError(GenericAuthException());
        }
      },
      codeSent: (verificationId, resendToken) {
        result.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return result.future;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> verifyPhoneNumber({
    required String verificationId,
    required String verificationCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: verificationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'session-expired') {
        throw SessionExpiredAuthException();
      } else if (e.code == 'credential-already-in-use') {
        throw PhoneNumberAlreadyInUseAuthException();
      } else {
        throw InvalidVerificationCodeAuthException();
      }
    }
  }

  Future<void> finishAccountSetup({
    required String email,
    required String firstName,
    required String lastName,
    required String userName,
    required String description,
    required XFile? image,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    final users = await FirebaseFirestore.instance
        .collection(userCollectionName)
        .where(userNamefield, isEqualTo: userName)
        .get();

    if (email.trim().isEmpty) throw NoEmailProvidedAuthException();

    if (userName.trim().isEmpty) throw NoUserNameProvidedAuthException();

    if (userName.trim().length < 8) throw UserNameTooShortAuthException();

    if (users.docs.isNotEmpty) throw UserNameAlreadyExistsAuthException();

    if (firstName.trim().isEmpty) throw NoFirstNameProvidedAuthException();

    if (lastName.trim().isEmpty) throw NoLastNameProvidedAuthException();

    if (image == null) throw NoProfilePictureProvidedAuthException();

    try {
      await user.updateEmail(email);
      final imageUrl = await _storageService.uploadImage(
        selectedPhoto: image,
        path: imagePath,
      );
      await user.updatePhotoURL(imageUrl);

      await db.doc(user.uid).set({
        userNamefield: userName,
        emailField: email,
        firstNameField: firstName,
        lastNameField: lastName,
        descriptionField: description,
        displayImageField: imageUrl,
        hoursWorkedField: 0.0,
        opportunitiesField: [],
        attendedField: [],
      });
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  Future<void> updateProfilePhoto({
    required XFile? photo,
  }) async {
    if (photo == null) {
      throw NoProfilePictureProvidedAuthException();
    }
    final imageUrl = await _storageService.uploadImage(
      selectedPhoto: photo,
      path: imagePath,
    );
    await db.doc(userDetails.uid).update({
      displayImageField: imageUrl,
    });
    await userDetails.updatePhotoURL(imageUrl);
  }

  Future<void> updatePhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await userDetails.updatePhoneNumber(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw InvalidVerificationCodeAuthException();
      } else if (e.code == 'credential-already-in-use') {
        throw PhoneNumberAlreadyInUseAuthException();
      } else {
        throw SessionExpiredAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  Future<void> updateEmail({
    required String email,
  }) async {
    if (email.trim().isEmpty) throw NoEmailProvidedAuthException();
    try {
      await userDetails.updateEmail(email);
      await userDetails.sendEmailVerification();
      await db.doc(userDetails.uid).update({
        emailField: email,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'requires-recent-login') {
        throw RequiresRecentLoginAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  Future<void> manageJoinStatus({
    required String opportunityId,
    required String userId,
  }) async {
    final query = await db.where(FieldPath.documentId, isEqualTo: userId).get();
    final user = AuthUser.fromFirebase(query.docs[0]);
    final opportunities = user.opportunities;

    if (opportunities.contains(opportunityId)) {
      opportunities.remove(opportunityId);
    } else {
      opportunities.add(opportunityId);
    }
    await db.doc(user.id).update({
      opportunitiesField: opportunities,
    });
  }

  Future<void> manageAttendedStatus({
    required String opportunityId,
    required String userId,
  }) async {
    final query = await db.where(FieldPath.documentId, isEqualTo: userId).get();
    final user = AuthUser.fromFirebase(query.docs[0]);
    if (user.attended.contains(opportunityId)) {
      user.attended.remove(opportunityId);
    } else {
      user.attended.add(opportunityId);
    }
    await db.doc(userId).update({
      attendedField: user.attended,
    });
  }

  Stream<List<AuthUser>> getUserListStream(opportunityId) {
    return db
        .where(opportunitiesField, arrayContains: opportunityId)
        .snapshots()
        .map((s) => s.docs.map(AuthUser.fromFirebase).toList());
  }

  Stream<AuthUser> getUserStream(String userId) => db
      .where(FieldPath.documentId, isEqualTo: userId)
      .snapshots()
      .map((s) => AuthUser.fromFirebase(s.docs[0]));
}
