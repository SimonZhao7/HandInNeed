import 'package:flutter/material.dart';
// Widgets
import '../widgets/button.dart';
// Firebase
import 'package:firebase_auth/firebase_auth.dart';
// Constants
import '../constants/routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
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
