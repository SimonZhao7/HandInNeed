import 'package:flutter/material.dart';
// Widgets
import 'package:flutter_slidable/flutter_slidable.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
// Constants
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
import 'package:hand_in_need/widgets/dialogs/delete_confirmation.dart';
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
    final opportunityService = OpportunityService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Attendees'),
      ),
      body: StreamBuilder(
        stream: opportunityService.getOpportunityStream(opportunityId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.done:
              final op = snapshot.data!;
              final eventEnded =
                  op.endTime.difference(DateTime.now()) <= Duration.zero;
              final differnce = op.endTime.difference(op.startTime);
              return StreamBuilder(
                stream: authService.getUserListStream(opportunityId),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final users = snapshot.data!;
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final attendConfirm =
                              user.attended.contains(opportunityId);
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
                                extentRatio: eventEnded ? 0.25 : 0.75,
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {},
                                    label: 'Profile',
                                    icon: Icons.account_circle,
                                    backgroundColor: const Color(secondary),
                                  ),
                                  if (!eventEnded) ...[
                                    SlidableAction(
                                      onPressed: (context) async {
                                        final value =
                                            await showDeleteConfirmationDialog(
                                                  context,
                                                  'Are you sure you want to remove this volunteer?',
                                                ) ??
                                                false;
                                        if (value) {
                                          await opportunityService
                                              .manageJoinStatus(
                                            opportunityId: opportunityId,
                                            userId: user.id,
                                          );
                                          await authService.manageJoinStatus(
                                            opportunityId: opportunityId,
                                            difference: differnce,
                                            userId: user.id,
                                          );
                                        }
                                      },
                                      label: 'Remove',
                                      icon: Icons.delete,
                                      backgroundColor: const Color(negativeRed),
                                      flex: 1,
                                    ),
                                    SlidableAction(
                                      padding: const EdgeInsets.all(10),
                                      onPressed: (context) async {
                                        await authService.manageAttendedStatus(
                                          opportunityId: opportunityId,
                                          difference: differnce,
                                          userId: user.id,
                                        );
                                      },
                                      label: attendConfirm
                                          ? 'Unconfirm'
                                          : 'Confirm',
                                      icon: attendConfirm
                                          ? Icons.check_box_outline_blank
                                          : Icons.check_box,
                                      backgroundColor: attendConfirm
                                          ? const Color(mediumGray)
                                          : const Color(positiveGreen),
                                      flex: 1,
                                    ),
                                  ]
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
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(user.email),
                                      Chip(
                                        backgroundColor: attendConfirm
                                            ? const Color(positiveGreen)
                                            : const Color(negativeRed),
                                        labelStyle: const TextStyle(
                                          color: Color(white),
                                        ),
                                        label: Text(
                                          attendConfirm
                                              ? 'Confirmed'
                                              : 'Unconfirmed',
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          );
                        },
                        itemCount: users.length,
                      );
                    default:
                      return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
