import 'package:flutter/material.dart';
import 'package:hand_in_need/constants/route_names.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
import '../services/notifications/notification_service.dart';
// Views
import 'package:hand_in_need/views/upcoming_opportunities_view.dart';
import 'package:hand_in_need/views/opportunity_tabs_view.dart';
import 'package:hand_in_need/views/account_settings_view.dart';
import 'package:hand_in_need/views/home_content_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final authService = AuthService();
  final notificationService = NotificationService();
  int _selectedIndex = 0;

  @override
  void initState() {
    notificationService.updateDeviceTokens(authService.userDetails.uid);
    super.initState();
  }

  @override
  void dispose() {
    notificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeContentView(),
          VolunteeringView(),
          OpportunityTabsView(),
          AccountSettingsView(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5,
        shape: const CircularNotchedRectangle(),
        elevation: 0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.transparent,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cases_outlined),
              label: 'Your Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_rounded),
              label: 'Account',
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          currentIndex: _selectedIndex,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(addOpportunity);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
