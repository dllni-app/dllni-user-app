import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../cl_booking/view/cl_booking_screen.dart';
import '../../cl_home/view/cl_home_screen.dart';
import '../../cl_offers/view/cl_offers_screen.dart';
import '../../cl_profile/view/cl_profile_screen.dart';

@AutoRoutePage(path: '/')
class ClMainScreen extends StatefulWidget {
  const ClMainScreen({super.key});

  @override
  State<ClMainScreen> createState() => _ClMainScreenState();
}

class _ClMainScreenState extends State<ClMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = <Widget>[
    ClHomeScreen(),
    ClOffersScreen(),
    ClBookingScreen(),
    ClProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer),
            label: 'Offers',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
