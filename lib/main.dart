import 'package:flutter/material.dart';
// Firebase
import 'package:hand_in_need/services/deep_links/deep_links_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Views
import 'package:hand_in_need/views/create_or_update_opportunity_view.dart';
import 'package:hand_in_need/views/update_phone_number_view.dart';
import 'package:hand_in_need/views/change_opportunity_email.dart';
import 'package:hand_in_need/views/opportunity_details_view.dart';
import 'package:hand_in_need/views/opportunity_signup_view.dart';
import 'package:hand_in_need/views/verify_attendence_view.dart';
import 'package:hand_in_need/views/setup_signup_password.dart';
import 'package:hand_in_need/views/manage_attendees_view.dart';
import 'package:hand_in_need/views/update_username_view.dart';
import 'package:hand_in_need/views/update_profile_photo.dart';
import 'package:hand_in_need/views/address_search_view.dart';
import 'package:hand_in_need/views/user_settings_view.dart';
import 'package:hand_in_need/views/account_setup_view.dart';
import 'package:hand_in_need/views/verify_phone_view.dart';
import 'package:hand_in_need/views/update_email_view.dart';
import 'package:hand_in_need/views/register_view.dart';
import 'package:hand_in_need/views/landing_view.dart';
import 'package:hand_in_need/views/home_view.dart';
// Services
import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_service.dart';
import 'package:hand_in_need/services/notifications/notification_service.dart';
import 'package:hand_in_need/services/auth/auth_constants.dart';
// Constants
import 'package:hand_in_need/constants/route_args/add_opportunity_args.dart';
import 'package:hand_in_need/constants/route_args/change_op_email_args.dart';
import 'package:hand_in_need/constants/route_args/id_args.dart';
import 'package:hand_in_need/constants/route_names.dart';
import 'package:hand_in_need/constants/colors.dart';
// Util
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void handleNotificationClick(NotificationResponse details) {
  navigatorKey.currentState?.pushNamed(verifyAttendence);
}

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  final plugin = FlutterLocalNotificationsPlugin();
  plugin.initialize(
    initSettings,
    onDidReceiveBackgroundNotificationResponse: handleNotificationClick,
    onDidReceiveNotificationResponse: handleNotificationClick,
  );
  plugin.getNotificationAppLaunchDetails();
  const notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'verify',
      'verify',
      channelDescription: 'verification for signups',
      importance: Importance.max,
      priority: Priority.max,
    ),
  );

  await plugin.show(
    0,
    message.notification!.title,
    message.notification!.body,
    notificationDetails,
    payload: message.data['signupId'] as String,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  FirebaseMessaging.onMessage.listen(_backgroundMessageHandler);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      routes: {
        landing: (context) => const Home(),
        home: (context) => const HomeView(),
        inputAddress: (context) => const AddressSearchView(),
        register: (context) => const RegisterView(),
        accountSetup: (context) => const AccountSetupView(),
        userSettings: (context) => const UserSettingsView(),
        updateProfilePhoto: (context) => const UpdateProfilePhotoView(),
        updatePhoneNumber: (context) => const UpdatePhoneNumberView(),
        updateEmail: (context) => const UpdateEmailView(),
        updateUsername: (context) => const UpdateUsernameView(),
        verifyAttendence: (context) => const VerifyAttendenceView(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == addOpportunity) {
          final ags = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => ags == null
                ? const AddOpportunity(opportunity: null)
                : AddOpportunity(
                    opportunity: (ags as AddOpportunityArgs).opportunity),
          );
        } else if (settings.name == changeOpportunityEmail) {
          final args = settings.arguments as ChangeOpportunityEmailArgs;
          return MaterialPageRoute(
            builder: (context) => ChangeOpportunityEmailView(
              emailHash: args.emailHash,
              opportunityId: args.opportunityId,
            ),
          );
        } else if (settings.name == manageAttendees) {
          final args = settings.arguments as IdArgs;
          return MaterialPageRoute(
            builder: (context) => ManageAttendeesView(
              opportunityId: args.id,
            ),
          );
        } else if (settings.name == viewOpportunity) {
          final args = settings.arguments as IdArgs;
          return MaterialPageRoute(
            builder: (context) => OpportunityDetailsView(
              opportunityId: args.id,
            ),
          );
        } else if (settings.name == opportunityPasswordSetup) {
          final args = settings.arguments as IdArgs;
          return MaterialPageRoute(
            builder: (context) => SetupSignupPasswordView(
              opportunityId: args.id,
            ),
          );
        } else if (settings.name == verifyPhone) {
          final args = settings.arguments as IdArgs;
          return MaterialPageRoute(
            builder: (context) => VerifyPhoneView(
              verificationId: args.id,
            ),
          );
        } else {
          return null;
        }
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final deepLinkService = DeepLinksService();
    final notificationService = NotificationService();
    final user = FirebaseAuth.instance.currentUser;

    deepLinkService.handleLinkClicks(context);
    notificationService.requestPermisstions();

    if (user == null) {
      return const LandingView();
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
            return const LandingView();
          } else {
            final opportunitySignupsService = OpportunitiesSignupsService();
            return StreamBuilder(
              stream: opportunitySignupsService.getExistingSignups(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.data != null) {
                      final signup = snapshot.data!;
                      return OpportunitySignupView(signup: signup);
                    } else {
                      // No Signup Popup
                      return const HomeView();
                    }
                  default:
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                }
              },
            );
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
