import 'package:flutter/material.dart';
import 'dart:async';
// Services
import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_exceptions.dart';
import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_service.dart';
import 'package:hand_in_need/services/notifications/notification_service.dart';
import '../services/opportunity_signups/opportunity_signup.dart';
import 'package:hand_in_need/services/auth/auth_exceptions.dart';
// Widgets
import 'package:hand_in_need/widgets/dialogs/dialog.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/input.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';

class OpportunitySignupView extends StatefulWidget {
  final OpportunitySignup signup;
  const OpportunitySignupView({super.key, required this.signup});

  @override
  State<OpportunitySignupView> createState() => _OpportunitySignupViewState();
}

class _OpportunitySignupViewState extends State<OpportunitySignupView> {
  final _opportunitySignupService = OpportunitiesSignupsService();
  final _notificationService = NotificationService();
  late TextEditingController _password;
  late TextEditingController _email;
  bool success = false;
  bool error = false;
  String? signUpEmail;

  Stream<int> getTimer({required int seconds}) async* {
    while (seconds > 0) {
      yield seconds;
      seconds--;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void initState() {
    _password = TextEditingController();
    _email = TextEditingController();
    _notificationService.updateDeviceTokens(widget.signup.userId);
    super.initState();
  }

  @override
  void dispose() {
    _password.dispose();
    _email.dispose();
    _notificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final verifiedEmail = widget.signup.verifiedEmail;

    if (verifiedEmail != null && !success && !error) {
      _opportunitySignupService
          .updateAttendanceStatus(
            id: widget.signup.id,
            enteredEmail: signUpEmail,
          )
          .then<void>((_) => {
                setState(() {
                  _email.text = '';
                  signUpEmail = null;
                  success = true;
                  error = false;
                })
              })
          .catchError((e) {
        if (e is AlreadyAttendedSignupsException) {
          setState(() {
            _email.text = '';
            signUpEmail = null;
            success = false;
            error = true;
          });
        } else {
          setState(() {
            _email.text = '';
            signUpEmail = null;
            success = false;
          });
        }
      });
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (success) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFA9E7A5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: const Text(
                      'You have successfully confirmed your attendance.',
                      style: TextStyle(
                        color: Color(0xFF094C05),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (error) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(negativeRed),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: const Text(
                      'You have already signed up for this event',
                      style: TextStyle(
                        color: Color(white),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text('Welcome!', style: textStyle.headline1),
                const SizedBox(height: 20),
                Text(
                  'Please confirm your attendance below',
                  style: textStyle.headline3,
                ),
                const SizedBox(height: 40),
                if (signUpEmail != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 20),
                      Text(
                        'Please continue the verification process through your phone.',
                        style: textStyle.labelMedium,
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder(
                        stream: getTimer(seconds: 60),
                        builder: (context, snapshot) {
                          final seconds = snapshot.data;
                          return Text(
                            'Time Remaining: $seconds seconds...',
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                Text(
                  'Email',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 5),
                Input(
                  controller: _email,
                  enabled: signUpEmail == null,
                ),
                const SizedBox(height: 10),
                Button(
                  onPressed: () async {
                    if (signUpEmail != null) return;
                    try {
                      await _opportunitySignupService.sendSignupNotification(
                        signup: widget.signup,
                        email: _email.text,
                      );
                      setState(() {
                        success = false;
                        error = false;
                        signUpEmail = _email.text;
                      });
                      Future.delayed(const Duration(minutes: 1), () {
                        setState(() {
                          signUpEmail = null;
                          _email.text = '';
                          success = false;
                          error = false;
                        });
                      });
                    } catch (e) {
                      if (e is InvalidEmailSignupsException) {
                        showErrorSnackbar(
                          context,
                          'Invalid email',
                        );
                      } else if (e is NotSignedUpForEventSignupsException ||
                          e is NotSignedInAuthException) {
                        showErrorSnackbar(
                          context,
                          'You are not signed up for this event',
                        );
                      } else {
                        showErrorSnackbar(
                          context,
                          'Something went wrong',
                        );
                      }
                    }
                  },
                  label: 'Confirm Attendence',
                  backgroundColor: signUpEmail != null ? 0xFF541212 : null,
                ),
                if (signUpEmail != null) ...[
                  const SizedBox(height: 20),
                  Button(
                    onPressed: () => {
                      setState(() {
                        _email.text = '';
                        signUpEmail = null;
                      })
                    },
                    label: 'Cancel',
                  ),
                ]
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                onPressed: () async {
                  try {
                    final res = await displayDialog(
                      context,
                      title: 'Enter your password',
                      content: Input(
                        controller: _password,
                        password: true,
                      ),
                      actions: [
                        {
                          'label': 'Cancel',
                          'val': false,
                        },
                        {
                          'label': 'Submit',
                          'val': true,
                        }
                      ],
                    );
                    if (res) {
                      await _opportunitySignupService.deleteSignup(
                        id: widget.signup.id,
                        password: _password.text,
                      );
                    }
                  } catch (e) {
                    if (e is IncorrectPasswordOpportunitySignupsException) {
                      showErrorSnackbar(
                        context,
                        'Incorrect Password',
                      );
                    } else {
                      showErrorSnackbar(
                        context,
                        'Something went wrong',
                      );
                    }
                  }
                },
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
