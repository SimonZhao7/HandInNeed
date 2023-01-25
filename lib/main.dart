import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// Views
import 'package:hand_in_need/views/register_view.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';
import 'package:hand_in_need/constants/routes.dart';
import 'package:hand_in_need/views/verify_phone_view.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          primaryColor: const Color(blue),
          fontFamily: 'Montserrat',
          textTheme: const TextTheme(
            headline1: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w500,
            ),
            headline3: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ).apply(
            displayColor: Colors.black,
            bodyColor: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              backgroundColor: const Color(black),
              foregroundColor: const Color(white),
              padding: const EdgeInsets.all(15),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.black,
            focusColor: Colors.white,
          )),
      home: const RegisterView(),
      routes: {
        registerRoute: (context) => const RegisterView(),
        verifyPhoneRoute: (context) => const VerifyPhoneView(),
      },
    );
  }
}
