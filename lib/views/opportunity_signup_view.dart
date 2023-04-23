import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_exceptions.dart';
import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_service.dart';
import 'package:hand_in_need/services/notifications/notification_service.dart';
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
import '../services/opportunity_signups/opportunity_signup.dart';
import 'package:hand_in_need/services/auth/auth_exceptions.dart';
// Widgets
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/dialogs/dialog.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/input.dart';


class OpportunitySignupView extends StatefulWidget {
  final OpportunitySignup signup;
  const OpportunitySignupView({super.key, required this.signup});

  @override
  State<OpportunitySignupView> createState() => _OpportunitySignupViewState();
}

class _OpportunitySignupViewState extends State<OpportunitySignupView> {
  final _opportunitySignupService = OpportunitiesSignupsService();
  final _notificationService = NotificationService();
  final _opportunityService = OpportunityService();
  late TextEditingController _password;
  late TextEditingController _email;
  String? signUpEmail;

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
    return Scaffold(
      body: StreamBuilder(
        stream: _opportunityService
            .getOpportunityStream(widget.signup.opportunityId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final op = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(30),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome!', style: textStyle.headline1),
                      const SizedBox(height: 20),
                      Text(
                        'Please confirm your attendance below',
                        style: textStyle.headline3,
                      ),
                      const SizedBox(height: 40),
                      if (signUpEmail != null)
                        Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 20),
                            Text(
                              'Please continue the verification process through your account...',
                              style: textStyle.labelMedium,
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
                          try {
                            await _opportunitySignupService
                                .sendSignupNotification(
                              signup: widget.signup,
                              email: _email.text,
                            );
                            setState(() {
                              signUpEmail = _email.text;
                            });
                          } catch (e) {
                            if (e is InvalidEmailSignupsException) {
                              showErrorSnackbar(
                                context,
                                'Invalid email',
                              );
                            } else if (e
                                    is NotSignedUpForEventSignupsException ||
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
                      ),
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
                          if (e
                              is IncorrectPasswordOpportunitySignupsException) {
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
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
