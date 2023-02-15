import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hand_in_need/firebase_options.dart';
import 'package:hand_in_need/views/login_view.dart';
import 'package:hand_in_need/views/main_app_home_view.dart';
import 'package:hand_in_need/views/register_view.dart';
import 'package:hand_in_need/views/verify_email_view.dart';

// TO DO
// LOGGING IN WITH GOOGLE AND FACEBOOK FOR HAND IN NEED APP
// 46:20
// Watch later vid to do this weekend start today

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginView(),
      routes: {
        'register': (context) => const RegisterView(),
        'login': (context) => const LoginView(),
        'verify-email': (context) => const VerifyEmail(),
        'home-view': (context) => const MyHome(),
      },
    );
  }
}
