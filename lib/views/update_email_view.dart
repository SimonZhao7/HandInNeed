import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_exceptions.dart';
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
import '../services/auth/auth_service.dart';
// Widgets
import 'package:hand_in_need/widgets/update_user_data_wrapper.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/input.dart';

class UpdateEmailView extends StatefulWidget {
  const UpdateEmailView({super.key});

  @override
  State<UpdateEmailView> createState() => _UpdateEmailViewState();
}

class _UpdateEmailViewState extends State<UpdateEmailView> {
  final _authService = AuthService();
  final _opportunityService = OpportunityService();
  late TextEditingController _email;

  @override
  void initState() {
    _email = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UpdateUserDataWrapper(
      title: 'Update Email',
      children: [
        Text(
          'New Email',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 10),
        Input(controller: _email),
        const SizedBox(height: 10),
        Button(
          onPressed: () async {
            final navigator = Navigator.of(context);
            try {
              final oldEmail = _authService.userDetails.email!;
              await _authService.updateEmail(email: _email.text);
              await _opportunityService.handleEmailChanges(
                oldEmail: oldEmail,
              );
              navigator.pop();
            } catch (e) {
              if (e is NoEmailProvidedAuthException) {
                showErrorSnackbar(context, 'No email provided');
              } else if (e is InvalidEmailAuthException) {
                showErrorSnackbar(context, 'Invalid email address');
              } else if (e is EmailAlreadyInUseAuthException) {
                showErrorSnackbar(context, 'Email already in use');
              } else if (e is RequiresRecentLoginAuthException) {
                showErrorSnackbar(
                  context,
                  'Please log in again before updating email',
                );
              } else {
                showErrorSnackbar(context, 'Something went wrong');
              }
            }
          },
          label: 'Update Email',
        ),
      ],
    );
  }
}
