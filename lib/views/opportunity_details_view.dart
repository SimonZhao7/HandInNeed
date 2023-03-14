import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
import '../services/opportunities/opportunity_service.dart';
// Widgets
import 'package:hand_in_need/widgets/error_snackbar.dart';
import 'package:hand_in_need/widgets/link_text.dart';
import 'package:hand_in_need/widgets/button.dart';
// Util
import 'package:transparent_image/transparent_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// Constants
import 'package:hand_in_need/constants/route_names.dart';

class OpportunityDetailsView extends StatelessWidget {
  final String opportunityId;
  const OpportunityDetailsView({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final opportunityService = OpportunityService();
    final textStyle = Theme.of(context).textTheme;
    final dateFormat = DateFormat.yMd().add_jm();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Details'),
      ),
      body: DefaultTextStyle(
        style: textStyle.labelMedium!,
        child: StreamBuilder(
          stream: opportunityService.getOpportunityStream(opportunityId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
              case ConnectionState.active:
                final opportunity = snapshot.data!;
                final place = opportunity.place;
                final owned = opportunity.organizationEmail ==
                    authService.userDetails.email;
                final started =
                    opportunity.startTime.difference(DateTime.now()) <=
                        Duration.zero;
                return ListView(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 250,
                        minWidth: double.infinity,
                      ),
                      child: Stack(
                        children: [
                          const Center(child: CircularProgressIndicator()),
                          FadeInImage.memoryNetwork(
                            fadeInDuration: const Duration(milliseconds: 250),
                            width: double.infinity,
                            image: opportunity.image,
                            fit: BoxFit.cover,
                            placeholder: kTransparentImage,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opportunity.title, style: textStyle.headline2),
                          const SizedBox(height: 25),
                          Text(opportunity.description),
                          const SizedBox(height: 40),
                          Text('Important Dates', style: textStyle.headline3),
                          const SizedBox(height: 15),
                          Text(
                            'Starts on: ${dateFormat.format(opportunity.startTime)}',
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Ends on: ${dateFormat.format(opportunity.endTime)}',
                          ),
                          const SizedBox(height: 40),
                          Text(place.name, style: textStyle.headline3),
                          const SizedBox(height: 15),
                          Text('Address: ${place.address}'),
                          const SizedBox(height: 15),
                          LinkText(
                            leading: 'Organization Website: ',
                            url: opportunity.url,
                            scheme: 'https',
                          ),
                          if (place.website != null) ...[
                            const SizedBox(height: 15),
                            LinkText(
                              leading: 'Place Website: ',
                              url: place.website ?? '',
                              scheme: 'https',
                            ),
                          ],
                          const SizedBox(height: 40),
                          Text('Contact Info', style: textStyle.headline3),
                          const SizedBox(height: 15),
                          if (place.phoneNumber != null) ...[
                            LinkText(
                              leading: 'Phone Number: ',
                              url: place.phoneNumber ?? '',
                              scheme: 'tel',
                            ),
                            const SizedBox(height: 15),
                          ],
                          LinkText(
                            leading: 'Email: ',
                            url: opportunity.organizationEmail,
                            scheme: 'mailto',
                          ),
                          const SizedBox(height: 40),
                          owned
                              ? Button(
                                  onPressed: () {
                                    if (started) {
                                      showErrorSnackbar(
                                        context,
                                        'You can not edit this opportunity because event has already begun',
                                      );
                                      return;
                                    }
                                    context.pushNamed(
                                      addOpportunity,
                                      extra: opportunity,
                                    );
                                  },
                                  label: 'Edit',
                                )
                              : Button(
                                  onPressed: () {
                                    if (started) {
                                      showErrorSnackbar(
                                        context,
                                        'You can not join this opportunity because event has already begun',
                                      );
                                      return;
                                    }
                                    opportunityService.manageJoinStatus(
                                      opportunityId: opportunity.id,
                                      userId: authService.userDetails.uid,
                                    );
                                    authService.manageJoinStatus(
                                      opportunityId: opportunity.id,
                                      userId: authService.userDetails.uid,
                                      difference:
                                          opportunity.endTime.difference(
                                        opportunity.startTime,
                                      ),
                                    );
                                  },
                                  label: opportunity.attendees
                                          .contains(authService.userDetails.uid)
                                      ? 'Leave'
                                      : 'Join',
                                )
                        ],
                      ),
                    )
                  ],
                );
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
