import 'package:flutter/material.dart';
// Services
import 'package:hand_in_need/services/auth/auth_service.dart';
// Views
import 'package:hand_in_need/views/home_content_view.dart';
import 'package:hand_in_need/views/opportunity_tabs_view.dart';
import 'package:hand_in_need/views/account_settings_view.dart';
import 'package:hand_in_need/views/upcoming_opportunities_view.dart';
// Constants
import '../constants/route_names.dart';
// Uitl
import 'package:go_router/go_router.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final authService = AuthService();
  final List<String> titles = ['Home', 'Upcoming', 'Your Jobs', 'Account'];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeContentView(),
          UpcomingOpportunitiesView(),
          OpportunityTabsView(),
          AccountSettingsView(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5,
        shape: const CircularNotchedRectangle(),
        elevation: 0,
        color: Colors.black,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.transparent,
          unselectedItemColor: const Color.fromARGB(180, 255, 255, 255),
          selectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Upcoming',
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
          context.pushNamed(addOpportunity);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
