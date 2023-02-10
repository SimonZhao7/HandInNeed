import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
// Widgets
import 'package:hand_in_need/widgets/button.dart';
// Constants
import 'package:hand_in_need/constants/routes.dart';


class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Button(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await authService.signOut();
              navigator.pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            label: 'Sign Out',
          ),
        ],
      ),
    );
  }
}
