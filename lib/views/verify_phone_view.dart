import 'package:flutter/material.dart';
import 'package:hand_in_need/services/auth/auth_exceptions.dart';
import 'package:hand_in_need/services/auth/auth_service.dart';
// Widgets
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/input.dart';
// Services
import '../services/auth/auth_user.dart';
// Constants
import 'package:hand_in_need/constants/routes.dart';

class VerifyPhoneView extends StatefulWidget {
  const VerifyPhoneView({super.key});

  @override
  State<VerifyPhoneView> createState() => _VerifyPhoneViewState();
}

class _VerifyPhoneViewState extends State<VerifyPhoneView> {
  final _authService = AuthService();
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
                      final navigator = Navigator.of(context);
                      final verificationCode = _verificationCode.text;

                      if (!focus.hasPrimaryFocus) {
                        focus.unfocus();
                      }

                      await _authService.verifyPhoneNumber(
                        verificationId: verificationId,
                        verificationCode: verificationCode,
                      );

                      final AuthUser? currentUser =
                          await _authService.currentUser();
                      if (currentUser == null) {
                        navigator.pushNamed(accountSetupRoute);
                      } else {
                        navigator.pushNamedAndRemoveUntil(
                          homeRoute,
                          (route) => false,
                        );
                      }
                    } on AuthException catch (e) {
                      if (e is InvalidVerificationCodeAuthException) {
                        showErrorSnackbar(
                          context,
                          'Invalid verification code',
                        );
                      } else if (e is SessionExpiredAuthException) {
                        showErrorSnackbar(
                          context,
                          'Expired verification code. Please log in again for another code',
                        );
                      } else {
                        showErrorSnackbar(
                          context,
                          'Something went wrong',
                        );
                      }
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
