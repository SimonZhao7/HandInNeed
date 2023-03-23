import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/opportunities/opportunity_view_type.dart';
import 'package:hand_in_need/widgets/opportunities_list.dart';

class OpportunityTabsView extends StatelessWidget {
  const OpportunityTabsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Jobs'),
          bottom: const TabBar(
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
        body: const TabBarView(
          children: [
            OpportunitiesList(
              type: OpportunityViewType.posted,
            ),
            OpportunitiesList(
              type: OpportunityViewType.manage,
            ),
          ],
        ),
      ),
    );
  }
}
