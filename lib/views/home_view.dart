import 'package:flutter/material.dart';
import 'package:hand_in_need/services/auth/auth_service.dart';
// Widgets
import '../widgets/button.dart';
// Constants
import '../constants/routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: Button(
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
        ),
      ),
    );
  }
}
