import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_exceptions.dart';
import 'package:hand_in_need/services/opportunity_signups/opportunity_signups_service.dart';
import 'package:hand_in_need/services/geolocator/geolocator_exceptions.dart';
import 'package:hand_in_need/services/geolocator/geolocator_service.dart';
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/constants/route_names.dart';
import 'package:hand_in_need/constants/colors.dart';
import 'package:hand_in_need/widgets/button.dart';
import 'package:flutter/material.dart';

class VerifyAttendenceView extends StatefulWidget {
  final String signupId;
  const VerifyAttendenceView({
    super.key,
    required this.signupId,
  });

  @override
  State<VerifyAttendenceView> createState() => _VerifyAttendenceViewState();
}

class _VerifyAttendenceViewState extends State<VerifyAttendenceView> {
  @override
  Widget build(BuildContext context) {
    final signupsService = OpportunitiesSignupsService();
    final geolocatorService = GeoLocatorService();
    final textTheme = Theme.of(context).textTheme;
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Attendence')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: StreamBuilder(
            stream: signupsService.getSignupStream(widget.signupId),
            builder: (context, snapshot) {
              final connState = snapshot.connectionState;
              if (connState == ConnectionState.active ||
                  connState == ConnectionState.done) {
                final signup = snapshot.data!;
                return FutureBuilder(
                    future: geolocatorService.getCurrentLocation(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (snapshot.error
                                is LocationPermissionDeniedGeolocatorException)
                              Text(
                                'Please enable location to verify your attendence',
                                style: textTheme.headline3,
                              ),
                            const SizedBox(height: 20),
                            Button(
                              onPressed: () => setState(() {}),
                              label: 'Enable Location',
                            ),
                          ],
                        );
                      }
                      final connState = snapshot.connectionState;
                      if (connState == ConnectionState.active ||
                          connState == ConnectionState.done) {
                        final location = snapshot.data!;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Verify Attendence',
                              style: textTheme.headline1,
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.width / 2),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      try {
                                        await signupsService.verifySignup(
                                          id: signup.id,
                                          location: location,
                                        );
                                        navigator.pushNamedAndRemoveUntil(
                                          home,
                                          (route) => false,
                                        );
                                      } catch (e) {
                                        if (e
                                            is DistanceTooFarSignupsException) {
                                          showErrorSnackbar(
                                            context,
                                            'You are too far from the volunteer location. Try again when you get closer.',
                                          );
                                        } else {
                                          showErrorSnackbar(
                                              context, 'Something went wrong');
                                        }
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(secondary),
                                      padding: const EdgeInsets.all(30),
                                      shape: const CircleBorder(),
                                    ),
                                    child: const Icon(Icons.check, size: 30),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      navigator.pop();
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(secondary),
                                      padding: const EdgeInsets.all(30),
                                      shape: const CircleBorder(),
                                    ),
                                    child: const Icon(Icons.close, size: 30),
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    });
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
