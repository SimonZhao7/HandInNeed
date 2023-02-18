import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hand_in_need/util/showSnackBar.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

Future<void> sendEmailVerify(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.sendEmailVerification();
    showSnackBar(context, 'An email has been sent please check your email');
  } else {
    showSnackBar(context,
        'Looks like error occured sending verification please try again');
  }
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: const Text('Verification'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
                "We've sent an email verification. Please open in order to verify your account"),
            const Text(
                "If you have not recieved an email verification yet press the button below to do so!"),
            TextButton(
                onPressed: () {
                  sendEmailVerify(context);
                },
                child: const Text('Send Email Verification')),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('login', (route) => false);
              },
              child: const Center(
                child: Text('Restart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
