import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
// Constants
import 'package:hand_in_need/constants/route_names.dart';
// Util
import 'package:go_router/go_router.dart';

class UserSettingsView extends StatelessWidget {
  const UserSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final textStyle = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: authService.getUserStream(authService.userDetails.uid),
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
                                authService.userDetails.phoneNumber!,
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
          ListTile(
            title: const Text('Update Profile Photo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(updateProfilePhoto),
          ),
          ListTile(
            title: const Text('Update Phone Number'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(updatePhoneNumber),
          ),
          ListTile(
            title: const Text('Update Email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(updateEmail),
          ),
          ListTile(
            title: const Text('Update Username'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
