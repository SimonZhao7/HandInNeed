import 'dart:async';
// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _googleSignIn = GoogleSignIn(scopes: [
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile'
  ]);
  AuthService.instance();
  factory AuthService() => _shared;

  final db = FirebaseFirestore.instance.collection(userCollectionName);
  final _storageService = CloudStorageService();

  User get userDetails => FirebaseAuth.instance.currentUser!;

  Future<AuthUser> getUser({
    required Object field,
    required Object value,
  }) async {
    try {
      return AuthUser.fromFirebase(
        (await db.where(field, isEqualTo: value).get()).docs.first,
      );
    } catch (_) {
      throw NotSignedInAuthException();
    }
  }

  Future<AuthUser> getUserFromEmail(String email) =>
      getUser(field: emailField, value: email);

  Future<AuthUser> getUserById(String id) =>
      getUser(field: FieldPath.documentId, value: id);

  Future<AuthUser> currentUser() => getUser(
        field: FieldPath.documentId,
        value: FirebaseAuth.instance.currentUser!.uid,
      );

  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      final authentication = await account!.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (_) {
      throw GoogleSignInAuthException();
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance
          .login(permissions: ['email', 'public_profile']);
      OAuthCredential credential = FacebookAuthProvider.credential(
        loginResult.accessToken!.token,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (_) {
      throw FacebookSignInAuthException();
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
    await _googleSignIn.signOut();
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
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'session-expired') {
        throw SessionExpiredAuthException();
      } else if (e.code == 'credential-already-in-use') {
        throw PhoneNumberAlreadyInUseAuthException();
      } else if (e.code == 'invalid-verification-code' ||
          e.code == 'invalid-verification-id') {
        throw InvalidVerificationCodeAuthException();
      } else {
        throw GenericAuthException();
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
        .where(userNameField, isEqualTo: userName)
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
        userNameField: userName,
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

  Future<void> updateUsername({required String username}) async {
    if (username.trim().isEmpty) throw NoUserNameProvidedAuthException();
    if (username.trim().length < 8) throw UserNameTooShortAuthException();
    final query = await db.where(userNameField, isEqualTo: username).get();
    if (query.docs.isNotEmpty) throw UserNameAlreadyExistsAuthException();
    await db.doc(userDetails.uid).update({
      userNameField: username,
    });
  }

  Future<void> updateHoursWorked({
    required String id,
    required double newHours,
  }) async {
    await db.doc(id).update({
      hoursWorkedField: newHours,
    });
  }

  Future<void> manageJoinStatus({
    required String opportunityId,
    required String userId,
    Duration? difference,
  }) async {
    final query = await db.where(FieldPath.documentId, isEqualTo: userId).get();
    final user = AuthUser.fromFirebase(query.docs[0]);
    final opportunities = user.opportunities;

    if (opportunities.contains(opportunityId)) {
      opportunities.remove(opportunityId);
      if (user.attended.contains(opportunityId)) {
        // assert difference != null
        manageAttendedStatus(
          opportunityId: opportunityId,
          difference: difference!,
          userId: userId,
        );
      }
    } else {
      opportunities.add(opportunityId);
    }
    await db.doc(user.id).update({
      opportunitiesField: opportunities,
    });
  }

  Future<void> manageAttendedStatus({
    required String opportunityId,
    required Duration difference,
    required String userId,
  }) async {
    final query = await db.where(FieldPath.documentId, isEqualTo: userId).get();
    final user = AuthUser.fromFirebase(query.docs[0]);
    final hours = difference.inMinutes / 60;
    late double newHours;

    if (user.attended.contains(opportunityId)) {
      user.attended.remove(opportunityId);
      newHours = user.hoursWorked - hours;
    } else {
      user.attended.add(opportunityId);
      newHours = user.hoursWorked + hours;
    }
    await db.doc(userId).update({
      attendedField: user.attended,
      hoursWorkedField: newHours,
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
