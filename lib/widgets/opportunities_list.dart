import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/opportunities/opportunity_view_type.dart';
import '../services/opportunities/opportunity_service.dart';
import '../services/opportunities/opportunity.dart';
// Widgets
import 'package:hand_in_need/widgets/button.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';
// Util
import 'package:intl/intl.dart';

class OpportunitiesList extends StatelessWidget {
  final Stream<List<Opportunity>> stream;
  final OpportunityViewType type;

  const OpportunitiesList({
    super.key,
    required this.stream,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final opportunityService = OpportunityService();
    final dateFormat = DateFormat.yMd();

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.done:
            final data = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 75),
              itemBuilder: (context, index) {
                final opportunity = data[index];
                final place = opportunity.place;
                final label = Theme.of(context).textTheme.labelMedium;

                return Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        const SizedBox(height: 5),
                        Chip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                opportunity.verified
                                    ? Icons.check_circle
                                    : Icons.warning_rounded,
                                color: const Color(white),
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                opportunity.verified
                                    ? 'Verified'
                                    : 'Unverified',
                              ),
                            ],
                          ),
                          backgroundColor: Color(opportunity.verified
                              ? positiveGreen
                              : negativeRed),
                          labelStyle: const TextStyle(
                            color: Color(white),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Start Date: ${dateFormat.format(opportunity.startDate)}',
                          style: label,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'From: ${TimeOfDay.fromDateTime(opportunity.startTime).format(context)}',
                              style: label,
                            ),
                            Text(
                              'To: ${TimeOfDay.fromDateTime(opportunity.endTime).format(context)}',
                              style: label,
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: type == OpportunityViewType.posted ||
                                        (type == OpportunityViewType.manage &&
                                            opportunity.verified)
                                    ? Button(
                                        onPressed: () {},
                                        label: 'View',
                                      )
                                    : Button(
                                        onPressed: () async {
                                          await opportunityService
                                              .verifyOpportunity(
                                            opportunity.id,
                                          );
                                        },
                                        label: 'Verify',
                                      )),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 1,
                              child: type == OpportunityViewType.manage &&
                                      opportunity.verified
                                  ? Button(
                                      onPressed: () {},
                                      label: 'Manage',
                                    )
                                  : const SizedBox(),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 15);
              },
              itemCount: data.length,
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
