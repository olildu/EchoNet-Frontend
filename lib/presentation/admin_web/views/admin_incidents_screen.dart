import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/tactical_theme.dart';
import '../../../logic/admin/admin_bloc.dart';

class AdminIncidentsScreen extends StatelessWidget {
  const AdminIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBloc()..add(LoadIncidents()),
      child: Scaffold(
        backgroundColor: TacticalColors.background,
        body: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: BlocBuilder<AdminBloc, AdminState>(
                      builder: (context, state) {
                        if (state.isLoading && state.incidents.isEmpty) {
                          return const Center(child: CircularProgressIndicator(color: TacticalColors.primaryContainer));
                        }
                        return Row(
                          children: [
                            _buildIncidentQueue(context, state),
                            Expanded(child: _buildIncidentDetails(context, state)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. SIDEBAR (Static for Layout) ---
  Widget _buildSidebar() {
    return Container(
      width: 240.w,
      color: TacticalColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              "ECHONET_OS",
              style: TextStyle(color: TacticalColors.primaryContainer, fontFamily: 'Space Grotesk', fontSize: 22.sp, fontWeight: FontWeight.w900, letterSpacing: 2.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "OPERATOR_01",
                  style: TextStyle(color: TacticalColors.primaryContainer, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                SizedBox(height: 4.h),
                Text(
                  "LEVEL_5_CLEARANCE",
                  style: TextStyle(color: Colors.white38, fontSize: 10.sp, letterSpacing: 1.0),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          _buildSidebarItem(Icons.map, "COMMAND MAP", isActive: false),
          _buildSidebarItem(Icons.warning, "INCIDENTS", isActive: true),
          _buildSidebarItem(Icons.people, "PERSONNEL", isActive: false),
          _buildSidebarItem(Icons.hub, "COMMS", isActive: false),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, {required bool isActive}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
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
          Icon(icon, color: isActive ? TacticalColors.primaryContainer : Colors.white38, size: 20.sp),
          SizedBox(width: 16.w),
          Text(
            label,
            style: TextStyle(color: isActive ? TacticalColors.primaryContainer : Colors.white38, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }

  // --- 2. TOP BAR ---
  Widget _buildTopBar() {
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
          Icon(Icons.sensors, color: Colors.white38, size: 20.sp),
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

  // --- 3. DYNAMIC INCIDENT QUEUE ---
  Widget _buildIncidentQueue(BuildContext context, AdminState state) {
    return Container(
      width: 380.w,
      decoration: BoxDecoration(
        color: TacticalColors.surfaceContainerLow,
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['ALL', 'PENDING', 'ASSIGNED'].map((tab) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(color: tab == 'ALL' ? TacticalColors.primaryContainer : Colors.transparent, borderRadius: BorderRadius.circular(4.r)),
                  child: Text(
                    tab,
                    style: TextStyle(color: tab == 'ALL' ? Colors.black : Colors.white54, fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.incidents.length,
              itemBuilder: (context, index) {
                final inc = state.incidents[index];
                bool isSelected = state.selectedIncident?['id'] == inc['id'];

                // Color Logic based on status/category
                Color priorityColor = inc['status'] == 'PENDING' ? TacticalColors.errorContainer : TacticalColors.secondaryContainer;

                return GestureDetector(
                  onTap: () => context.read<AdminBloc>().add(SelectIncident(inc)),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: isSelected ? TacticalColors.surfaceContainerHighest : TacticalColors.surfaceContainer,
                      border: isSelected
                          ? Border(
                              right: BorderSide(color: TacticalColors.primaryContainer, width: 4.w),
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.emergency, color: priorityColor, size: 24.sp),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                border: Border.all(color: priorityColor),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                inc['status'].toString().toUpperCase(),
                                style: TextStyle(color: priorityColor, fontSize: 9.sp, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "INC_${inc['id'].substring(0, 6).toUpperCase()}",
                          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Category: ${inc['category']}",
                          style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. DYNAMIC INCIDENT DETAILS & DISPATCH ---
  Widget _buildIncidentDetails(BuildContext context, AdminState state) {
    if (state.selectedIncident == null) {
      return Center(
        child: Text(
          "SELECT AN INCIDENT TO TRIAGE",
          style: TextStyle(color: Colors.white24, fontSize: 18.sp, fontWeight: FontWeight.bold, letterSpacing: 2.0),
        ),
      );
    }

    final inc = state.selectedIncident!;

    return Container(
      color: TacticalColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(40.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Text(
              "SYSTEM_LIVE_TRIAGE",
              style: TextStyle(color: TacticalColors.primaryContainer, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 2.0),
            ),
            SizedBox(height: 12.h),
            Text(
              "${inc['category']} OPERATION",
              style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 42.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
            ),
            SizedBox(height: 48.h),

            // DISTRESS TRANSMISSION
            Text(
              "CITIZEN_DISTRESS_TRANSMISSION",
              style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.bold, letterSpacing: 2.0),
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: TacticalColors.surfaceContainerLow,
                border: Border(
                  left: BorderSide(color: TacticalColors.primaryContainer, width: 4.w),
                ),
              ),
              child: Text(
                '"${inc['description']}"',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontStyle: FontStyle.italic, height: 1.6),
              ),
            ),
            SizedBox(height: 48.h),

            // DYNAMIC RESPONDER MATCHING
            Text(
              "NEAREST_RESPONDER_MATCHING",
              style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.bold, letterSpacing: 2.0),
            ),
            SizedBox(height: 16.h),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: TacticalColors.primaryContainer),
              )
            else if (state.responders.isEmpty)
              Text(
                "NO AVAILABLE RESPONDERS FOUND IN RADIUS.",
                style: TextStyle(color: TacticalColors.errorContainer, fontSize: 12.sp, fontWeight: FontWeight.bold),
              )
            else
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                      color: TacticalColors.surfaceContainerHighest.withOpacity(0.5),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              "OPERATIVE",
                              style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "DIST",
                              style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "ACTION",
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...state.responders.map((volunteer) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                volunteer['name'],
                                style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "${volunteer['distance_meters']} M",
                                style: TextStyle(color: TacticalColors.primaryContainer, fontSize: 13.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<AdminBloc>().add(DispatchVolunteer(inc['id'], volunteer['id']));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                                    decoration: BoxDecoration(color: TacticalColors.primaryContainer, borderRadius: BorderRadius.circular(4.r)),
                                    child: Text(
                                      "DISPATCH",
                                      style: TextStyle(color: Colors.black, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
