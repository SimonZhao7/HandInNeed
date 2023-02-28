import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';
// Util
import 'package:transparent_image/transparent_image.dart';

class ManageAttendeesView extends StatelessWidget {
  final String opportunityId;
  const ManageAttendeesView({
    super.key,
    required this.opportunityId,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Attendees'),
      ),
      body: StreamBuilder(
        stream: authService.getUserListStream(opportunityId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.done:
              final users = snapshot.data!;
              return ListView.separated(
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      tileColor: const Color(white),
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: FadeInImage.memoryNetwork(
                          image: user.displayImage,
                          placeholder: kTransparentImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        '${user.firstName} ${user.lastName}',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      subtitle: Text(user.email),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
                itemCount: users.length,
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
