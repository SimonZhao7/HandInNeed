import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
import 'package:hand_in_need/widgets/dialogs/delete_confirmation.dart';
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
    final opportunityService = OpportunityService();

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
              return ListView.builder(
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color(white),
                      boxShadow: [
                        BoxShadow(
                          color: Color(mediumGray),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async {
                              final value = await showDeleteConfirmationDialog(
                                    context,
                                    'Are you sure you want to remove this volunteer?',
                                  ) ??
                                  false;
                              if (value) {
                                await opportunityService.manageJoinStatus(
                                  opportunityId: opportunityId,
                                  userId: user.userId,
                                );
                                await authService.manageJoinStatus(
                                  opportunityId: opportunityId,
                                  userId: user.userId,
                                );
                              }
                            },
                            label: 'Remove',
                            icon: Icons.delete,
                            backgroundColor: const Color(negativeRed),
                            flex: 1,
                          ),
                          SlidableAction(
                            onPressed: (context) {},
                            label: 'Confirm',
                            icon: Icons.check_box,
                            backgroundColor: const Color(positiveGreen),
                            flex: 1,
                          ),
                        ],
                      ),
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
                    ),
                  );
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
