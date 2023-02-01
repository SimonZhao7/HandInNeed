import 'dart:async';
import 'dart:io';
// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Auth
import 'package:hand_in_need/services/auth/auth_constants.dart';
import 'package:hand_in_need/services/auth/auth_user.dart';
// Util
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
// Exceptions
import 'auth_exceptions.dart';

class AuthService {
  static final AuthService _shared = AuthService.instance();
  AuthService.instance();
  factory AuthService() => _shared;

  Future<AuthUser?> currentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final id = user.uid;
    final query = await FirebaseFirestore.instance
        .collection(userCollectionName)
        .where(userIdField, isEqualTo: id)
        .get();

    if (query.docs.isEmpty) {
      return null;
    } else {
      final data = query.docs[0];
      return AuthUser.fromFirebase(data);
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
      final ref = FirebaseStorage.instance.ref(
        '$imagePath${const Uuid().v4()}-${image.name}',
      );
      final uploadState = ref.putFile(File(image.path));

      uploadState.snapshotEvents.listen((TaskSnapshot event) async {
        switch (event.state) {
          case TaskState.paused:
            break;
          case TaskState.running:
            break;
          case TaskState.canceled:
            break;
          case TaskState.error:
            break;
          case TaskState.success:
            final url = await ref.getDownloadURL();
            await user.updatePhotoURL(url);
        }
      });

      await FirebaseFirestore.instance.collection(userCollectionName).add({
        userIdField: user.uid,
        userNamefield: userName,
        firstNameField: firstName,
        lastNameField: lastName,
        descriptionField: description,
        hoursWorkedField: 0.0,
        opportunitiesField: [],
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
}
