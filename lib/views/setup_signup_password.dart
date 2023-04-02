import 'package:flutter/material.dart';
import 'package:hand_in_need/constants/route_names.dart';
import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_exceptions.dart';
import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_service.dart';
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/input.dart';
import 'package:go_router/go_router.dart';

class SetupSignupPasswordView extends StatefulWidget {
  final String opportunityId;
  const SetupSignupPasswordView({super.key, required this.opportunityId});

  @override
  State<SetupSignupPasswordView> createState() =>
      _SetupSignupPasswordViewState();
}

class _SetupSignupPasswordViewState extends State<SetupSignupPasswordView> {
  late TextEditingController _password;
  late TextEditingController _confirmPassword;
  final _opportunitySignupService = OpportunitiesSignupsService();

  @override
  void initState() {
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium!;
    return Scaffold(
      appBar: AppBar(title: const Text('Password Setup')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Password', style: labelStyle),
            const SizedBox(height: 5),
            Input(controller: _password, password: true),
            const SizedBox(height: 10),
            Text('Confirm Password', style: labelStyle),
            const SizedBox(height: 5),
            Input(controller: _confirmPassword, password: true),
            const SizedBox(height: 10),
            Button(
              onPressed: () async {
                try {
                  final router = GoRouter.of(context);
                  await _opportunitySignupService.createSignup(
                    password: _password.text,
                    confirmPassword: _confirmPassword.text,
                    opportunityId: widget.opportunityId,
                  );
                  router.goNamed(landing);
                } catch (e) {
                  if (e is PasswordTooShortOpportunitySignupsException) {
                    showErrorSnackbar(
                      context,
                      'Provided password must be 8 characters long',
                    );
                  } else if (e
                      is PasswordsDoNotMatchOpportunitySignupsException) {
                    showErrorSnackbar(
                      context,
                      'Passwords do not match',
                    );
                  } else {
                    showErrorSnackbar(
                      context,
                      'Something went wrong',
                    );
                  }
                }
              },
              label: 'Setup Signup Page',
            )
          ],
        ),
      ),
    );
  }
}
