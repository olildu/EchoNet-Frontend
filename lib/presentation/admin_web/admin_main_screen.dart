import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/presentation/admin_web/views/admin_map_view.dart';
import 'package:frontend/presentation/admin_web/views/admin_personnel_view.dart';
import 'package:frontend/presentation/theme/tactical_theme.dart';
import '../../../data/services/websocket_service.dart';
import '../../../logic/admin/admin_bloc.dart';
import 'views/admin_incidents_screen.dart';
import 'views/admin_comms_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false; // Tracks sidebar state

  final List<Widget> _views = [const AdminMapView(), const AdminIncidentsScreen(), const AdminPersonnelView(), const AdminCommsScreen()];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBloc(context.read<WebSocketService>())..add(LoadIncidents()),
      // CRITICAL FIX: The Builder widget provides a new BuildContext that sits *below* // the BlocProvider in the tree, allowing us to find the AdminBloc easily.
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            backgroundColor: TacticalColors.background,
            body: Row(
              children: [
                _buildSidebar(innerContext),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(innerContext),
                      Expanded(
                        child: IndexedStack(index: _selectedIndex, children: _views),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutQuart,
      width: _isSidebarCollapsed ? 65.w : 240.w, // Smoothly animate width
      color: TacticalColors.surfaceContainerLow,
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: 240.w, // Keeps internal layout steady during collapse
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebarHeader(),
                _buildSidebarItem(0, Icons.map, "COMMAND MAP"),
                _buildSidebarItem(1, Icons.warning, "INCIDENTS"),
                _buildSidebarItem(2, Icons.people, "PERSONNEL"),
                _buildSidebarItem(3, Icons.hub, "COMMS"),
                const Spacer(),
                _buildSidebarItem(-1, Icons.logout, "LOGOUT", onTap: () => Navigator.pushReplacementNamed(context, '/')),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, top: 24.h, bottom: 24.h),
      child: Row(
        children: [
          // Hamburger Toggle Button
          GestureDetector(
            onTap: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(4.w),
              child: Icon(_isSidebarCollapsed ? Icons.menu : Icons.menu_open, color: TacticalColors.primaryContainer, size: 28.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            "ECHONET_OS",
            style: TextStyle(
              color: TacticalColors.primaryContainer,
              fontFamily: 'Space Grotesk',
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label, {VoidCallback? onTap}) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _selectedIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isActive ? TacticalColors.surfaceContainerHighest.withOpacity(0.3) : Colors.transparent,
          border: isActive
              ? Border(
                  left: BorderSide(color: TacticalColors.primaryContainer, width: 4.w),
                )
              : null,
        ),
        child: Row(
          children: [
            SizedBox(width: 24.w), // Aligns perfectly under the hamburger icon
            Icon(icon, color: isActive ? TacticalColors.primaryContainer : Colors.white38, size: 24.sp),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                color: isActive ? TacticalColors.primaryContainer : Colors.white38,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 70.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: TacticalColors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.sensors, color: TacticalColors.primaryContainer, size: 24.sp),
            tooltip: "Force System Sync",
            onPressed: () {
              // Now using the Builder's context, this will find the AdminBloc perfectly
              context.read<AdminBloc>().add(LoadIncidents());
              context.read<AdminBloc>().add(LoadPersonnel());

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("INITIATING MANUAL SYSTEM SYNC...", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  backgroundColor: TacticalColors.secondaryContainer,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          SizedBox(width: 24.w),
          CircleAvatar(
            radius: 16.r,
            backgroundColor: TacticalColors.surfaceContainerHighest,
            child: Icon(Icons.person, color: TacticalColors.primaryContainer, size: 16.sp),
          ),
        ],
      ),
    );
  }
}
