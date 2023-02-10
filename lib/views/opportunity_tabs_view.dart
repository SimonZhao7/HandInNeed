import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/opportunities/opportunity_service.dart';
import 'package:hand_in_need/services/opportunities/opportunity_view_type.dart';
import 'package:hand_in_need/widgets/opportunities_list.dart';

class OpportunityTabsView extends StatelessWidget {
  const OpportunityTabsView({super.key});

  @override
  Widget build(BuildContext context) {
    final opportunityService = OpportunityService();
    final yourOpportunities = opportunityService.yourOpportunities();
    final manageOpportunities = opportunityService.manageOpportunities();

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const TabBar(
            tabs: [
              Tab(
                icon: Text('Your Posts'),
              ),
              Tab(
                icon: Text('Your Hostings'),
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OpportunitiesList(
              stream: yourOpportunities,
              type: OpportunityViewType.posted,
            ),
            OpportunitiesList(
              stream: manageOpportunities,
              type: OpportunityViewType.manage,
            ),
          ],
        ),
      ),
    );
  }
}
