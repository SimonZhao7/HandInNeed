import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
// Extensions
import 'package:hand_in_need/extensions/navigator.dart';
// Views
import 'package:hand_in_need/views/update_email_view.dart';
import 'package:hand_in_need/views/update_phone_number_view.dart';
import 'package:hand_in_need/views/update_profile_photo.dart';
import 'package:hand_in_need/views/update_username_view.dart';
// Widgets
import 'package:hand_in_need/widgets/button.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';

class UserSettingsView extends StatefulWidget {
  const UserSettingsView({super.key});

  @override
  State<UserSettingsView> createState() => _UserSettingsViewState();
}

class _UserSettingsViewState extends State<UserSettingsView> {
  final _authService = AuthService();
  bool verificationSent = false;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: _authService.getUserStream(_authService.userDetails.uid),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                case ConnectionState.active:
                  final user = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                200,
                              ),
                            ),
                            child: Image.network(
                              user.displayImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.userName,
                                style: textStyle.headline3,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${user.firstName} ${user.lastName}',
                                style: textStyle.labelMedium,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                user.email,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _authService.userDetails.phoneNumber!,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                default:
                  return Container();
              }
            },
          ),
          if (!_authService.userDetails.emailVerified) ...[
            const SizedBox(width: 20),
            Container(
              margin: const EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(primary),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your email isn\'t verified yet!',
                    style: textStyle.labelMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: Button(
                      onPressed: () async {
                        if (!verificationSent) {
                          await _authService.userDetails
                              .sendEmailVerification();
                          setState(() {
                            verificationSent = true;
                          });
                        }
                      },
                      label: verificationSent
                          ? 'Verification Sent'
                          : 'Resend Verification',
                      fontSize: 16,
                      backgroundColor: accent,
                    ),
                  )
                ],
              ),
            ),
          ],
          ListTile(
            title: const Text('Update Profile Photo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => navigator.pushSlideRoute(
              const UpdateProfilePhotoView(),
            ),
          ),
          ListTile(
            title: const Text('Update Phone Number'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => navigator.pushSlideRoute(
              const UpdatePhoneNumberView(),
            ),
          ),
          ListTile(
            title: const Text('Update Email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => navigator.pushSlideRoute(
              const UpdateEmailView(),
            ),
          ),
          ListTile(
            title: const Text('Update Username'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => navigator.pushSlideRoute(
              const UpdateUsernameView(),
            ),
          ),
        ],
      ),
    );
  }
}
