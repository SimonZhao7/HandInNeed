import 'package:flutter/material.dart';
import 'package:hand_in_need/constants/colors.dart';
import 'package:hand_in_need/services/auth/auth_exceptions.dart';
import 'package:hand_in_need/services/auth/auth_service.dart';
// Widgets
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/input.dart';
// Constants
import 'package:hand_in_need/constants/route_names.dart';


class VerifyPhoneView extends StatefulWidget {
  final String verificationId;
  const VerifyPhoneView({super.key, required this.verificationId});

  @override
  State<VerifyPhoneView> createState() => _VerifyPhoneViewState();
}

class _VerifyPhoneViewState extends State<VerifyPhoneView> {
  final _authService = AuthService();
  late TextEditingController _verificationCode;
  late String verificationId;

  @override
  void initState() {
    verificationId = widget.verificationId;
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
    final navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(primary),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hold On...',
                    style: Theme.of(context).textTheme.headline1),
                const SizedBox(height: 50),
                Text('Please enter the 6 digit verification code sent to you',
                    style: Theme.of(context).textTheme.headline3),
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
                      final focus = FocusScope.of(context);
                      final verificationCode = _verificationCode.text;

                      if (!focus.hasPrimaryFocus) {
                        focus.unfocus();
                      }

                      await _authService.verifyPhoneNumber(
                        verificationId: verificationId,
                        verificationCode: verificationCode,
                      );
                      try {
                        await _authService.currentUser();
                        navigator.pushNamedAndRemoveUntil(
                          home,
                          (_) => false,
                        );
                      } on NotSignedInAuthException {
                        navigator.pushNamed(accountSetup);
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
                      } else if (e is PhoneNumberAlreadyInUseAuthException) {
                        showErrorSnackbar(
                          context,
                          'Phone number is already in use',
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
                  navigator.pushNamedAndRemoveUntil(register, (_) => false);
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
