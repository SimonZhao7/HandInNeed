import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_exceptions.dart';
import 'package:hand_in_need/services/auth/auth_service.dart';
// Widgets
import 'package:hand_in_need/widgets/update_user_data_wrapper.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/button.dart';
import 'package:hand_in_need/widgets/input.dart';

class UpdateUsernameView extends StatefulWidget {
  const UpdateUsernameView({super.key});

  @override
  State<UpdateUsernameView> createState() => _UpdateUsernameViewState();
}

class _UpdateUsernameViewState extends State<UpdateUsernameView> {
  final _authService = AuthService();
  late TextEditingController _username;

  @override
  void initState() {
    _username = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UpdateUserDataWrapper(
      title: 'Update Username',
      children: [
        Text(
          'New Username',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 10),
        Input(controller: _username),
        const SizedBox(height: 10),
        Button(
          onPressed: () async {
            try {
              final navigator = Navigator.of(context);
              await _authService.updateUsername(
                username: _username.text,
              );
              navigator.pop();
            } catch (e) {
              if (e is NoUserNameProvidedAuthException) {
                showErrorSnackbar(
                  context,
                  'No username provided',
                );
              } else if (e is UserNameTooShortAuthException) {
                showErrorSnackbar(
                  context,
                  'Username must be at least 8 characters long',
                );
              } else if (e is UserNameAlreadyExistsAuthException) {
                showErrorSnackbar(
                  context,
                  'Username is already in use',
                );
              }
            }
          },
          label: 'Update Username',
        ),
      ],
    );
  }
}
