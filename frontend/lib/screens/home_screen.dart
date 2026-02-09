import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'explore_tab.dart';
import 'saved_tab.dart';
import 'trips_tab.dart';
import 'messages_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const ExploreTab(),
    const SavedTab(),
    const TripsTab(),
    const MessagesTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(LineIcons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(LineIcons.heart), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(LineIcons.suitcase), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(LineIcons.comments), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(LineIcons.user), label: 'Profile'),
        ],
      ),
    );
  }
}
