import 'package:flutter/material.dart';
// Firebase
import 'package:hand_in_need/services/deep_links/deep_links_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Views
import 'package:hand_in_need/views/create_or_update_opportunity_view.dart';
import 'package:hand_in_need/views/update_phone_number_view.dart';
import 'package:hand_in_need/views/change_opportunity_email.dart';
import 'package:hand_in_need/views/opportunity_details_view.dart';
import 'package:hand_in_need/views/manage_attendees_view.dart';
import 'package:hand_in_need/views/update_username_view.dart';
import 'package:hand_in_need/views/update_profile_photo.dart';
import 'package:hand_in_need/views/address_search_view.dart';
import 'package:hand_in_need/views/user_settings_view.dart';
import 'package:hand_in_need/views/account_setup_view.dart';
import 'package:hand_in_need/views/verify_phone_view.dart';
import 'package:hand_in_need/views/update_email_view.dart';
import 'package:hand_in_need/views/register_view.dart';
import 'package:hand_in_need/views/home_view.dart';
// Services
import 'package:hand_in_need/services/auth/auth_constants.dart';
import 'services/opportunities/opportunity.dart';
// Constants
import 'package:hand_in_need/constants/route_names.dart';
import 'package:hand_in_need/constants/colors.dart';
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
      builder: (context, state) => const AddressSearchView(),
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
      path: '/auth/user-settings',
      name: userSettings,
      builder: (context, state) => const UserSettingsView(),
    ),
    GoRoute(
      path: '/auth/update/photo',
      name: updateProfilePhoto,
      builder: (context, state) => const UpdateProfilePhotoView(),
    ),
    GoRoute(
      path: '/auth/update/phone-number',
      name: updatePhoneNumber,
      builder: (context, state) => const UpdatePhoneNumberView(),
    ),
    GoRoute(
      path: '/auth/update/email',
      name: updateEmail,
      builder: (context, state) => const UpdateEmailView(),
    ),
    GoRoute(
      path: '/auth/update/username',
      name: updateUsernmae,
      builder: (context, state) => const UpdateUsernameView(),
    ),
    GoRoute(
      path: '/opportunities/add',
      name: addOpportunity,
      builder: (context, state) => AddOpportunity(
        opportunity: state.extra as Opportunity?,
      ),
    ),
    GoRoute(
      path: '/opportunities/details/:id',
      name: viewOpportunity,
      builder: (context, state) => OpportunityDetailsView(
        opportunityId: state.params['id']!,
      ),
    ),
    GoRoute(
      path: '/opportunties/:id/manage',
      name: manageAttendees,
      builder: (context, state) => ManageAttendeesView(
        opportunityId: state.params['id']!,
      ),
    ),
    GoRoute(
      path: '/opportunities/change-email/:id/:emailHash',
      name: changeOpportunityEmail,
      builder: (context, state) => ChangeOpportunityEmailView(
        opportunityId: state.params['id']!,
        emailHash: state.params['emailHash']!,
      ),
    )
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(primary),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            color: Color(white),
          ),
          iconTheme: IconThemeData(color: Color(white)),
        ),
        tabBarTheme: const TabBarTheme(
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: Color(accent),
              width: 5,
            ),
          ),
          labelColor: Color(white),
        ),
        bottomAppBarTheme: const BottomAppBarTheme(color: Color(primary)),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(white),
          unselectedItemColor: Color(gray),
        ),
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
          labelMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ).apply(
          displayColor: Colors.black,
          bodyColor: Colors.black,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(primary),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: const Color(black),
            foregroundColor: const Color(white),
            padding: const EdgeInsets.all(15),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(accent),
          focusColor: Colors.white,
        ),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final deepLinkService = DeepLinksService();
    final user = FirebaseAuth.instance.currentUser;

    deepLinkService.handleLinkClicks(context);

    if (user == null) {
      return const RegisterView();
    }
    final userData = FirebaseFirestore.instance
        .collection(userCollectionName)
        .where(FieldPath.documentId, isEqualTo: user.uid)
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
