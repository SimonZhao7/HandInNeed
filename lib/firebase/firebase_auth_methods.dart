import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../util/showSnackBar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/oauth2/v2.dart';

class FirebaseAuthMethods {
  // create a firebase auth instance
  final FirebaseAuth _auth;
  FirebaseAuthMethods(this._auth);

  // email with sign up
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    // used display a suppose snackbar or other info
    required BuildContext context,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // upoun registering we want to send an email verification
      await sendEmailVerification(context);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
  // Email Login

  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // check when logging in if the user email is not verified
      if (!_auth.currentUser!.emailVerified) {
        // send email verification
        await sendEmailVerification(context);
        // take them to email verify view
        Navigator.of(context)
            .pushNamedAndRemoveUntil('verify-email', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  // Email verification
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      await _auth.currentUser!.sendEmailVerification();
      showSnackBar(context, 'Email verification has been sent');
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
}
