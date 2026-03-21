import 'package:flutter/material.dart';
import 'package:frontend/presentation/citizen/dashboard/citizen_dashboard.dart';
import 'package:frontend/presentation/citizen/dashboard/maps_screen.dart';
import 'package:frontend/presentation/citizen/dashboard/reports_screen.dart';
import 'package:frontend/presentation/citizen/dashboard/system_screen.dart';
import 'package:frontend/presentation/widgets/tactical_bottom_nav.dart';
import '../theme/tactical_theme.dart';

class CitizenMainScreen extends StatefulWidget {
  const CitizenMainScreen({super.key});

  @override
  State<CitizenMainScreen> createState() => _CitizenMainScreenState();
}

class _CitizenMainScreenState extends State<CitizenMainScreen> {
  int _selectedIndex = 0;

  final _pages = [CitizenDashboard(), ReportsScreen(), MapsScreen(), SettingsScreen()];

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
          TacticalNavItem(label: "PROFILE", icon: Icons.person_outline),
        ],
      ),
    );
  }
}
