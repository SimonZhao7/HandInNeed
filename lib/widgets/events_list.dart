import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/opportunities/opportunity.dart';
import '../services/opportunities/opportunity_service.dart';
// Widgets
import 'package:hand_in_need/widgets/button.dart';
// Constants
import '../constants/route_names.dart';
// Util
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';

class EventsList extends StatelessWidget {
  final Stream<List<Opportunity>> stream;
  EventsList({super.key, required this.stream});
  final opportunityService = OpportunityService();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.done:
            final data = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                final op = data[index];
                return Card(
                  elevation: 3,
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
            );
          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }
}
