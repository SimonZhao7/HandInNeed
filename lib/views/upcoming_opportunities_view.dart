import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
// Constants
import 'package:hand_in_need/widgets/events_list.dart';

class VolunteeringView extends StatefulWidget {
  const VolunteeringView({super.key});

  @override
  State<VolunteeringView> createState() => _VolunteeringViewState();
}

class _VolunteeringViewState extends State<VolunteeringView> {
  final opportunityService = OpportunityService();
  bool past = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Upcoming',
              ),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EventsList(
              stream: opportunityService.upcomingOpportunities(past: false),
            ),
            EventsList(
              stream: opportunityService.upcomingOpportunities(past: true),
            )
          ],
        ),
      ),
    );
  }
}
