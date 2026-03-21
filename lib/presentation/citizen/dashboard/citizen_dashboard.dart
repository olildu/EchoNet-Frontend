import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // NEW IMPORT
import 'package:frontend/presentation/theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import '../../../logic/incident/incident_history_bloc.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  @override
  State<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  @override
  void initState() {
    super.initState();
    // Fetch real data on load
    context.read<IncidentHistoryBloc>().add(FetchMyIncidents());
  }

  // --- Dynamic UI Mapping Logic ---
  String _getTimeAgo(String? isoDate) {
    if (isoDate == null) return "JUST NOW";
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return "${diff.inMinutes} MIN AGO";
      if (diff.inHours < 24) return "${diff.inHours}H AGO";
      return "${diff.inDays}D AGO";
    } catch (e) {
      return "RECENTLY";
    }
  }

  Widget _buildDynamicReportCard(dynamic incident) {
    final category = incident['category'] ?? 'GENERAL';
    final status = incident['status'] ?? 'PENDING';
    final description = incident['description'] ?? 'No description provided.';
    final timeAgo = _getTimeAgo(incident['reported_at']);

    IconData icon = Icons.warning;
    String title = category;
    if (category == 'MEDICAL') {
      icon = Icons.medical_services;
      title = "Medical Emergency";
    } else if (category == 'FLOOD') {
      icon = Icons.water_drop;
      title = "Severe Flooding";
    } else if (category == 'FIRE') {
      icon = Icons.local_fire_department;
      title = "Fire Incident";
    } else if (category == 'RESCUE') {
      icon = Icons.emergency;
      title = "Rescue Operation";
    }

    Color statusBgColor = TacticalColors.surfaceContainerHighest;
    Color statusTextColor = Colors.white;
    String statusText = status;
    if (status == 'ASSIGNED' || status == 'IN_PROGRESS') {
      statusBgColor = TacticalColors.secondaryContainer;
      statusTextColor = Colors.black;
      statusText = "HELP EN ROUTE";
    } else if (status == 'RESOLVED') {
      statusBgColor = Colors.white24;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h), // Scaled
      child: _buildReportCard(
        icon: icon,
        title: title.toUpperCase(),
        description: description,
        statusText: statusText,
        statusBgColor: statusBgColor,
        statusTextColor: statusTextColor,
        timeAgo: timeAgo,
        distance: "NEARBY",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h), // Scaled
                    _buildRadarSOS(),
                    SizedBox(height: 32.h), // Scaled
                    Center(
                      child: Text(
                        "HOLD TO BROADCAST DISTRESS SIGNAL",
                        style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w600, letterSpacing: 3.0),
                      ),
                    ),
                    SizedBox(height: 48.h), // Scaled
                    // LIVE DYNAMIC REPORTS SECTION
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w), // Scaled
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("MY REPORTS"),
                          SizedBox(height: 24.h), // Scaled

                          BlocBuilder<IncidentHistoryBloc, IncidentHistoryState>(
                            builder: (context, state) {
                              if (state is IncidentHistoryLoading) {
                                return const Center(child: CircularProgressIndicator(color: TacticalColors.primaryContainer));
                              } else if (state is IncidentHistoryLoaded) {
                                if (state.incidents.isEmpty) {
                                  return Text(
                                    "No incidents reported yet.",
                                    style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                                  );
                                }
                                // Only show the 2 most recent on the dashboard
                                final recentIncidents = state.incidents.take(2).toList();
                                return Column(children: recentIncidents.map((incident) => _buildDynamicReportCard(incident)).toList());
                              } else if (state is IncidentHistoryFailure) {
                                return Text(
                                  state.error,
                                  style: TextStyle(color: TacticalColors.errorContainer, fontSize: 14.sp),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                          SizedBox(height: 32.h), // Scaled
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- RESPONSIVE UI HELPER METHODS ---

  Widget _buildRadarSOS() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 320.w, // Scaled Width
            height: 320.w, // Kept to width to remain a perfect circle
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.03), width: 1.w),
            ),
          ),
          Container(
            width: 240.w, // Scaled
            height: 240.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.w),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/report_emergency'),
            child: Container(
              width: 170.w, // Scaled
              height: 170.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: TacticalColors.sosGradient,
                boxShadow: [BoxShadow(color: TacticalColors.primaryContainer.withOpacity(0.3), blurRadius: 40.r, spreadRadius: 5.r)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w), // Scaled
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(8.r)),
                    child: Icon(Icons.priority_high, color: TacticalColors.primaryContainer, size: 24.sp),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "SOS / REPORT\nINCIDENT",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white, fontFamily: 'Space Grotesk', fontSize: 20.sp, fontWeight: FontWeight.w900, letterSpacing: 2.0),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(height: 1.h, color: Colors.white10),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h), // Scaled
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.sensors, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                "ECHONET",
                style: TextStyle(color: Colors.white, fontFamily: 'Space Grotesk', fontSize: 18.sp, fontWeight: FontWeight.bold, letterSpacing: 2.0),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(color: TacticalColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16.r)),
            child: Row(
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: const BoxDecoration(color: TacticalColors.primary, shape: BoxShape.circle),
                ),
                SizedBox(width: 6.w),
                Text(
                  "OFFLINE - P2P ACTIVE",
                  style: TextStyle(color: Colors.white70, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String description,
    required String statusText,
    required Color statusBgColor,
    required Color statusTextColor,
    required String timeAgo,
    required String distance,
  }) {
    return TacticalCard(
      padding: EdgeInsets.all(24.w), // Scaled
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: const BoxDecoration(color: TacticalColors.surfaceContainerHigh, shape: BoxShape.circle),
                child: Icon(icon, color: TacticalColors.primary, size: 20.sp),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(20.r)),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusTextColor, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(color: Colors.white54, fontSize: 14.sp, height: 1.5),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.white38, size: 14.sp),
              SizedBox(width: 6.w),
              Text(
                timeAgo,
                style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 24.w),
              Icon(Icons.location_on_outlined, color: Colors.white38, size: 14.sp),
              SizedBox(width: 6.w),
              Text(
                distance,
                style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
