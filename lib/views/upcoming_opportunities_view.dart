import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
// Widgets
import 'package:hand_in_need/widgets/button.dart';
// Constants
import 'package:hand_in_need/constants/route_names.dart';
// Util
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';


class UpcomingOpportunitiesView extends StatefulWidget {
  const UpcomingOpportunitiesView({super.key});

  @override
  State<UpcomingOpportunitiesView> createState() =>
      _UpcomingOpportunitiesViewState();
}

class _UpcomingOpportunitiesViewState extends State<UpcomingOpportunitiesView> {
  final opportunityService = OpportunityService();
  bool past = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                past = !past;
              });
            },
            child: Chip(
              label: Text(past ? 'Active' : 'Past'),
              backgroundColor: Colors.black,
              labelStyle: textTheme.labelMedium!.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          StreamBuilder(
            stream: opportunityService.upcomingOpportunities(past),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data!;
                  return Expanded(
                    flex: 1,
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        final op = data[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  op.title,
                                  style: textTheme.headline3,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  timeago.format(
                                    allowFromNow: true,
                                    op.startDate,
                                  ),
                                  style: textTheme.labelMedium,
                                ),
                                const SizedBox(height: 20),
                                Button(
                                  onPressed: () {
                                    context.pushNamed(
                                      viewOpportunity,
                                      params: {'id': op.id},
                                    );
                                  },
                                  label: 'View',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 10,
                      ),
                      itemCount: data.length,
                    ),
                  );
                default:
                  return const Expanded(
                    flex: 1,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
              }
            },
          )
        ],
      ),
    );
  }
}
