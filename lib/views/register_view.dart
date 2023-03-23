import 'package:flutter/material.dart';
import 'package:hand_in_need/constants/colors.dart';
// Services
import 'package:hand_in_need/services/auth/auth_exceptions.dart';
import 'package:hand_in_need/services/auth/auth_service.dart';
// Widgets
import 'package:hand_in_need/widgets/input.dart';
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
// Constants
import 'package:hand_in_need/constants/route_names.dart';
// Util
import 'package:go_router/go_router.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _authService = AuthService();
  late TextEditingController _phoneNumber;

  @override
  void initState() {
    _phoneNumber = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(primary)),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Let's Begin!",
              style: Theme.of(context).textTheme.headline1,
            ),
            const SizedBox(height: 50),
            Text(
              'Please enter your phone number',
              style: Theme.of(context).textTheme.headline3,
            ),
            const SizedBox(height: 40),
            Input(
              controller: _phoneNumber,
              hint: 'E.g. 444-444-4444',
              type: TextInputType.phone,
              borderWidth: 2,
            ),
            const SizedBox(height: 40),
            Button(
              onPressed: () async {
                final focus = FocusScope.of(context);
                final phoneNumber = _phoneNumber.text;

                if (!focus.hasPrimaryFocus) {
                  focus.unfocus();
                }

                try {
                  final verificationId =
                      await _authService.sendPhoneVerification(
                    phoneNumber: phoneNumber,
                  );
                  _navigateToVerification(verificationId);
                } on AuthException catch (e) {
                  if (e is InvalidPhoneNumberAuthException) {
                    showErrorSnackbar(
                      context,
                      'Please enter a valid phone number',
                    );
                  } else if (e is TooManyRequestsAuthException) {
                    showErrorSnackbar(
                      context,
                      'Too many sign in attempts. Please try again later',
                    );
                  } else {
                    showErrorSnackbar(
                      context,
                      'Something went wrong',
                    );
                  }
                }
              },
              center: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward_outlined),
                ],
              ),
              height: 55,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToVerification(String verificationId) {
    context.pushNamed(
      verifyPhone,
      params: {
        'verificationId': verificationId,
      },
    );
    _phoneNumber.text = '';
  }
}
