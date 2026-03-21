import 'package:flutter/material.dart';
import 'package:frontend/presentation/volunteer/dashboard/messages_screen.dart';
import 'package:frontend/presentation/volunteer/dashboard/task_details_screen.dart';
import 'package:frontend/presentation/volunteer/dashboard/volunteer_maps_screen.dart';
import 'package:frontend/presentation/volunteer/dashboard/volunteer_profile_screen.dart';
import 'package:frontend/presentation/widgets/tactical_bottom_nav.dart';
import '../theme/tactical_theme.dart';
import 'dashboard/volunteer_dashboard.dart';

class VolunteerMainScreen extends StatefulWidget {
  const VolunteerMainScreen({super.key});

  @override
  State<VolunteerMainScreen> createState() => _VolunteerMainScreenState();
}

class _VolunteerMainScreenState extends State<VolunteerMainScreen> {
  int _selectedIndex = 0;

  // Replace placeholders with actual screens as you build them
  final List<Widget> _pages = [const VolunteerDashboard(), TaskDetailsScreen(), VolunteerMapsScreen(), MessagesScreen(), VolunteerProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: SafeArea(
        child: Column(children: [Expanded(child: _pages[_selectedIndex])]),
      ),
      bottomNavigationBar: TacticalBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
        items: [
          TacticalNavItem(label: "HOME", icon: Icons.tv_rounded),
          TacticalNavItem(label: "TASKS", icon: Icons.assignment_outlined),
          TacticalNavItem(label: "MAP", icon: Icons.explore_outlined),
          TacticalNavItem(label: "CHAT", icon: Icons.chat_bubble_outline, hasNotification: true),
          TacticalNavItem(label: "PROFILE", icon: Icons.person_outline),
        ],
      ),
    );
  }
}
