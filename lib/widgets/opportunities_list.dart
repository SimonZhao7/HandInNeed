import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/opportunities/opportunity_view_type.dart';
import '../services/opportunities/opportunity_service.dart';
import '../services/opportunities/opportunity.dart';
// Widgets
import 'package:hand_in_need/widgets/button.dart';
// Constants
import 'package:hand_in_need/constants/route_names.dart';
import 'package:hand_in_need/constants/colors.dart';
// Util
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class OpportunitiesList extends StatefulWidget {
  final OpportunityViewType type;

  const OpportunitiesList({
    super.key,
    required this.type,
  });

  @override
  State<OpportunitiesList> createState() => _OpportunitiesListState();
}

class _OpportunitiesListState extends State<OpportunitiesList> {
  final opportunityService = OpportunityService();
  bool past = false;

  @override
  Widget build(BuildContext context) {
    final yourOpportunities = opportunityService.yourOpportunities(past);
    final manageOpportunities = opportunityService.manageOpportunities(past);
    final dateFormat = DateFormat.yMd();

    return StreamBuilder(
      stream: widget.type == OpportunityViewType.posted
          ? yourOpportunities
          : manageOpportunities,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.done:
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      past = !past;
                    }),
                    child: Chip(
                      label: Text(past ? 'Active Posts' : 'Past Posts'),
                      backgroundColor: Colors.black,
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 10),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      child: Button(
                                        onPressed: () {
                                          context.pushNamed(
                                            viewOpportunity,
                                            params: {'id': opportunity.id},
                                          );
                                        },
                                        label: 'View',
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      flex: 1,
                                      child: _renderButton(
                                        opportunity,
                                        context,
                                      ),
                                    ),
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
                    ),
                  ),
                ],
              ),
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _renderButton(Opportunity opportunity, BuildContext context) {
    if (widget.type == OpportunityViewType.manage) {
      return opportunity.verified
          ? Button(
              onPressed: () {
                context.pushNamed(
                  manageAttendees,
                  params: {
                    'id': opportunity.id,
                  },
                );
              },
              label: 'Manage',
            )
          : Button(
              onPressed: () async {
                await opportunityService.verifyOpportunity(
                  opportunity.id,
                );
              },
              label: 'Verify',
            );
    } else {
      return const SizedBox();
    }
  }
}
