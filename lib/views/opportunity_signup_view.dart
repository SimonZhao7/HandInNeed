import 'package:flutter/material.dart';
import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_exceptions.dart';
import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_service.dart';
import 'package:hand_in_need/widgets/dialogs/dialog.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/input.dart';

import '../services/opportunity_signups/opportunity_signup.dart';

class OpportunitySignupView extends StatefulWidget {
  final OpportunitySignup signup;
  const OpportunitySignupView({super.key, required this.signup});

  @override
  State<OpportunitySignupView> createState() => _OpportunitySignupViewState();
}

class _OpportunitySignupViewState extends State<OpportunitySignupView> {
  final _opportunitySignupService = OpportunitiesSignupsService();
  late TextEditingController _password;

  @override
  void initState() {
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [],
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
