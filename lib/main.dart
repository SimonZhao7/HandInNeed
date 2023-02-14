import 'package:flutter/material.dart';
// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Views
import 'package:hand_in_need/widgets/autocomplete/address_search.dart';
import 'package:hand_in_need/views/opportunity_details_view.dart';
import 'package:hand_in_need/views/add_opportunity_view.dart';
import 'package:hand_in_need/views/account_setup_view.dart';
import 'package:hand_in_need/views/verify_phone_view.dart';
import 'package:hand_in_need/views/register_view.dart';
import 'package:hand_in_need/views/home_view.dart';
// Services
import 'services/opportunities/opportunity.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';
import 'package:hand_in_need/constants/route_names.dart';
// Router
import 'package:go_router/go_router.dart';
// Util
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Home(),
    ),
    GoRoute(
      path: '/home',
      name: home,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/address/input',
      name: inputAddress,
      builder: (context, state) => const AddressSearch(),
    ),
    GoRoute(
      path: '/auth/register',
      name: register,
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      name: accountSetup,
      path: '/auth/setup',
      builder: (context, state) => const AccountSetupView(),
    ),
    GoRoute(
      path: '/auth/verify-phone/:verificationId',
      name: verifyPhone,
      builder: (context, state) => VerifyPhoneView(
        verificationId: state.params['verificationId']!,
      ),
    ),
    GoRoute(
      path: '/opportunities/add',
      name: addOpportunity,
      builder: (context, state) => const AddOpportunity(),
    ),
    GoRoute(
      path: '/opportunities/details',
      name: viewOpportunity,
      builder: (context, state) => OpportunityDetailsView(
        opportunity: state.extra! as Opportunity,
      ),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(blue),
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          headline1: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w500,
          ),
          headline2: TextStyle(
            fontSize: 28,
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
        ),
      ),
      routerConfig: _router,
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
