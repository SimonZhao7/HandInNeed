import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hand_in_need/views/account_setup_view.dart';
import 'package:hand_in_need/views/home_view.dart';
// Views
import 'package:hand_in_need/views/register_view.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';
import 'package:hand_in_need/constants/routes.dart';
import 'package:hand_in_need/views/verify_phone_view.dart';
import 'package:hand_in_need/widgets/autocomplete/address_search.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env');
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
            labelMedium: TextStyle(fontSize: 16),
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
      home: const Home(),
      routes: {
        registerRoute: (context) => const RegisterView(),
        verifyPhoneRoute: (context) => const VerifyPhoneView(),
        accountSetupRoute: (context) => const AccountSetupView(),
        inputAddressRoute: (context) => const AddressSearch(),
        homeRoute: (context) => const HomeView(),
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const RegisterView();
    }
    final userData = FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: user.uid)
        .get();
    return FutureBuilder(
      future: userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          if (data.docs.isEmpty) {
            return const AccountSetupView();
          } else {
            return const HomeView();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
