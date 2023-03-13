import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
import '../services/auth/auth_exceptions.dart';
// Widgets
import 'package:hand_in_need/widgets/update_user_data_wrapper.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/input.dart';

class UpdatePhoneNumberView extends StatefulWidget {
  const UpdatePhoneNumberView({super.key});

  @override
  State<UpdatePhoneNumberView> createState() => _UpdatePhoneNumberViewState();
}

class _UpdatePhoneNumberViewState extends State<UpdatePhoneNumberView> {
  final _authService = AuthService();
  late TextEditingController _phoneNumber;
  late TextEditingController _verifyCode;
  String? verificationId;

  @override
  void initState() {
    _phoneNumber = TextEditingController();
    _verifyCode = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumber.dispose();
    _verifyCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;

    return UpdateUserDataWrapper(
      title: 'Update Phone Number',
      children: [
        Text(
          'New Phone Number',
          style: textStyle.labelMedium,
        ),
        const SizedBox(height: 10),
        Input(
          controller: _phoneNumber,
          enabled: verificationId == null,
          type: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        if (verificationId != null) ...[
          Text('Verification Code', style: textStyle.labelMedium),
          Input(
            controller: _verifyCode,
            type: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          Button(
            onPressed: () async {
              try {
                final navigator = Navigator.of(context);
                await _authService.updatePhoneNumber(
                  verificationId: verificationId!,
                  smsCode: _verifyCode.text,
                );
                navigator.pop();
              } catch (e) {
                if (e is InvalidVerificationCodeAuthException) {
                  showErrorSnackbar(
                    context,
                    'Invalid verification code',
                  );
                } else if (e is SessionExpiredAuthException) {
                  showErrorSnackbar(
                    context,
                    'Expired verification code. Please re-send to try again.',
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
            label: 'Confirm Update',
          ),
          const SizedBox(height: 10),
          Button(
            onPressed: () {
              _verifyCode.clear();
              setState(() {
                verificationId = null;
              });
            },
            label: 'Edit Phone Number',
          ),
        ],
        if (verificationId == null)
          Button(
            onPressed: () async {
              try {
                final id = await _authService.sendPhoneVerification(
                  phoneNumber: _phoneNumber.text,
                );
                setState(() {
                  verificationId = id;
                });
              } catch (e) {
                if (e is InvalidPhoneNumberAuthException) {
                  showErrorSnackbar(
                    context,
                    'Invalid phone number',
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
            label: 'Send Verification Code',
          ),
      ],
    );
  }
}
