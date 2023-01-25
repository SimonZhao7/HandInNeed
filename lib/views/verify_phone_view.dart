import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/input.dart';

class VerifyPhoneView extends StatefulWidget {
  const VerifyPhoneView({super.key});

  @override
  State<VerifyPhoneView> createState() => _VerifyPhoneViewState();
}

class _VerifyPhoneViewState extends State<VerifyPhoneView> {
  late TextEditingController _verificationCode;

  @override
  void initState() {
    _verificationCode = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _verificationCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hold On...',
                  style: Theme.of(context).textTheme.headline1,
                ),
                const SizedBox(height: 50),
                Text(
                  'Please enter the 6 digit verification code sent to you',
                  style: Theme.of(context).textTheme.headline3,
                ),
                const SizedBox(height: 40),
                Input(
                  controller: _verificationCode,
                  type: TextInputType.number,
                  maxLength: 6,
                  borderWidth: 2,
                  hint: 'E.g. 123456',
                ),
                const SizedBox(height: 40),
                Button(
                  onPressed: () async {
                    try {
                      final verificationId =
                          ModalRoute.of(context)?.settings.arguments as String;
                      final focus = FocusScope.of(context);
                      final credential = PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: _verificationCode.text,
                      );

                      if (!focus.hasPrimaryFocus) {
                        focus.unfocus();
                      }

                      final user = await FirebaseAuth.instance
                          .signInWithCredential(credential);
                    } on FirebaseAuthException catch (_) {
                      showErrorSnackbar(
                        context,
                        'Invalid verification code',
                      );
                    }
                  },
                  label: 'Next',
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                },
                child: const Icon(
                  Icons.arrow_back_sharp,
                  size: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
