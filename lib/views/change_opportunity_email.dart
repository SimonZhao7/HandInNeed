import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/opportunities/opportunity_exceptions.dart';
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
// Widgets
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/input.dart';


class ChangeOpportunityEmailView extends StatefulWidget {
  final String emailHash;
  final String opportunityId;
  const ChangeOpportunityEmailView({
    super.key,
    required this.emailHash,
    required this.opportunityId,
  });

  @override
  State<ChangeOpportunityEmailView> createState() =>
      _ChangeOpportunityEmailViewState();
}

class _ChangeOpportunityEmailViewState
    extends State<ChangeOpportunityEmailView> {
  final _opportunityService = OpportunityService();
  late TextEditingController _email;
  late TextEditingController _confirmEmail;
  late String emailHash;
  late String opportunityId;

  @override
  void initState() {
    emailHash = widget.emailHash;
    opportunityId = widget.opportunityId;
    _email = TextEditingController();
    _confirmEmail = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _confirmEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Opportunity')),
      body: DefaultTextStyle(
        style: textStyles.labelMedium!,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
          children: [
            Text(
              'Warning: this change is final.',
              style: textStyles.headline2,
            ),
            const SizedBox(height: 15),
            Text(
              'You will lose ownership of this event',
              style: textStyles.headline3,
            ),
            const SizedBox(height: 60),
            const Text('New Email'),
            Input(controller: _email),
            const Text('Confirm Email'),
            Input(controller: _confirmEmail),
            const SizedBox(height: 10),
            Button(
              onPressed: () async {
                final navigator = Navigator.of(context);
                try {
                  final email = _email.text;
                  final confirmEmail = _confirmEmail.text;
                  await _opportunityService.transferOwnership(
                    id: opportunityId,
                    newEmail: email,
                    confirmEmail: confirmEmail,
                    hash: emailHash,
                  );
                  navigator.pop();
                } catch (e) {
                  if (e is DoesNotExistOpportunityException ||
                      e is EmailMismatchOpportunityException) {
                    showErrorSnackbar(context, 'Invalid email url');
                  } else if (e
                      is InvalidOrganizationEmailOpportunityException) {
                    showErrorSnackbar(
                      context,
                      'Invalid Email',
                    );
                  } else if (e is EmailsDoNotMatchOpportunityException) {
                    showErrorSnackbar(
                      context,
                      'Provided emails do not match',
                    );
                  } else if (e is EmailNotChangedOpportunityException) {
                    showErrorSnackbar(
                      context,
                      'Provided email is the same as the current organization email',
                    );
                  } else {
                    showErrorSnackbar(context, 'Something went wrong');
                  }
                }
              },
              label: 'Transfer Ownership',
            )
          ],
        ),
      ),
    );
  }
}
