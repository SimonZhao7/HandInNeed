import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_exceptions.dart';
import 'package:hand_in_need/services/auth/auth_service.dart';
// Widgets
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/button.dart';
// Constants
import 'package:hand_in_need/constants/route_names.dart';
import 'package:hand_in_need/constants/colors.dart';
// Util
import 'package:go_router/go_router.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Scaffold(
      backgroundColor: const Color(primary),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 120),
                child: Text(
                  'HandInNeed',
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(color: const Color(white)),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Image.asset('assets/logo.png'),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button(
                    onPressed: () async {
                      try {
                        final router = GoRouter.of(context);
                        await authService.signInWithGoogle();
                        await authService.currentUser();
                        router.goNamed(home);
                      } catch (e) {
                        if (e is GoogleSignInAuthException) {
                          showErrorSnackbar(context, 'Google sign in failed');
                        } else if (e is NotSignedInAuthException) {
                          final authDetails = authService.userDetails;
                          if (authDetails.phoneNumber == null) {
                            context.goNamed(register);
                          } else {
                            context.goNamed(accountSetup);
                          }
                        } else {
                          showErrorSnackbar(context, 'Something went wrong');
                        }
                      }
                    },
                    label: 'Sign In With Google',
                    borderRadius: 9999,
                    backgroundColor: white,
                    textColor: black,
                    icon: SizedBox(
                      height: 35,
                      width: 35,
                      child: Image.asset('assets/google.png'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Button(
                    onPressed: () async {
                      try {
                        final router = GoRouter.of(context);
                        await authService.signInWithFacebook();
                        await authService.currentUser();
                        router.goNamed(home);
                      } catch (e) {
                        if (e is FacebookSignInAuthException) {
                          showErrorSnackbar(
                            context,
                            'Facebook sign in failed',
                          );
                        } else if (e is NotSignedInAuthException) {
                          if (authService.userDetails.phoneNumber == null) {
                            context.pushNamed(register);
                          } else {
                            context.pushNamed(accountSetup);
                          }
                        } else {
                          showErrorSnackbar(
                            context,
                            'Something went wrong',
                          );
                        }
                      }
                    },
                    label: 'Sign In With Facebook',
                    borderRadius: 9999,
                    backgroundColor: 0xFF3B579D,
                    textColor: white,
                    icon: const Icon(
                      Icons.facebook,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Button(
                    onPressed: () async {
                      context.goNamed(register);
                    },
                    label: 'Sign In With Phone Number',
                    borderRadius: 9999,
                    backgroundColor: white,
                    textColor: black,
                    icon: const Icon(
                      Icons.phone,
                      color: Color(black),
                      size: 35,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
