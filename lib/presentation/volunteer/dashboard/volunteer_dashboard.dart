import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import '../../../logic/task/task_bloc.dart';
import '../../../logic/task/available_tasks_bloc.dart';
import '../../../logic/profile/profile_bloc.dart';
import '../../../data/session_manager.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  bool _isAvailable = true;
  String _userName = "Commander";

  @override
  void initState() {
    super.initState();
    context.read<AvailableTasksBloc>().add(FetchAvailableTasks());
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final session = SessionManager();
    final name = await session.getFullName();
    final userId = await session.getUserId();

    if (name != null && mounted) {
      setState(() {
        _userName = name.split(' ').first;
      });
    }

    if (userId != null && mounted) {
      context.read<ProfileBloc>().add(FetchProfileStats(userId));
    }
  }

  String _getTimeAgo(String? isoDate) {
    if (isoDate == null) return "JUST NOW";
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return "${diff.inMinutes} MIN AGO";
      if (diff.inHours < 24) return "${diff.inHours}H AGO";
      return "${diff.inDays}D AGO";
    } catch (e) {
      return "RECENT";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskAcceptedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: TacticalColors.secondaryContainer));
          context.read<AvailableTasksBloc>().add(FetchAvailableTasks());
        } else if (state is TaskFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: TacticalColors.errorContainer));
        }
      },
      child: Scaffold(
        backgroundColor: TacticalColors.background,
        body: RefreshIndicator(
          color: TacticalColors.primaryContainer,
          backgroundColor: TacticalColors.surfaceContainerHigh,
          onRefresh: () async {
            context.read<AvailableTasksBloc>().add(FetchAvailableTasks());
            final userId = await SessionManager().getUserId();
            if (userId != null) context.read<ProfileBloc>().add(FetchProfileStats(userId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildAppBar(),
                SizedBox(height: 32.h),

                Text(
                  "Hello, $_userName 👋",
                  style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 32.sp, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Ready to respond?",
                  style: TextStyle(color: Colors.white54, fontSize: 16.sp),
                ),
                SizedBox(height: 32.h),

                _buildStatusToggle(),
                SizedBox(height: 24.h),

                // DYNAMIC TASK FEED
                BlocBuilder<AvailableTasksBloc, AvailableTasksState>(
                  builder: (context, state) {
                    if (state is AvailableTasksLoading) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: const Center(child: CircularProgressIndicator(color: TacticalColors.primaryContainer)),
                      );
                    } else if (state is AvailableTasksLoaded) {
                      if (state.incidents.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStandbyCard(),
                            SizedBox(height: 32.h),
                            Text(
                              "Nearby Incidents",
                              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16.h),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.w),
                                child: Text(
                                  "No active emergencies reported in your sector.",
                                  style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      final urgentTask = state.incidents.first;
                      final nearbyTasks = state.incidents.skip(1).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUrgentAlertCard(context, urgentTask),
                          SizedBox(height: 32.h),
                          Text(
                            "Nearby Incidents",
                            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16.h),
                          ...nearbyTasks.map((task) => _buildDynamicIncidentCard(task)),
                        ],
                      );
                    } else if (state is AvailableTasksFailure) {
                      return Center(
                        child: Text(
                          state.error,
                          style: TextStyle(color: TacticalColors.errorContainer, fontSize: 14.sp),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),

                SizedBox(height: 32.h),

                // DYNAMIC STATS ROW
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    String completed = "--";
                    String active = "--";
                    String hours = "--";

                    if (state is ProfileLoaded) {
                      completed = state.stats['tasks_completed'].toString();
                      active = state.stats['active_tasks'].toString();
                      hours = "${state.stats['hours_logged']}h";
                    }

                    return Row(
                      children: [
                        Expanded(child: _buildStatItem(completed, "TASKS\nCOMPLETED")),
                        SizedBox(width: 12.w),
                        Expanded(child: _buildStatItem(active, "ACTIVE TASKS")),
                        SizedBox(width: 12.w),
                        Expanded(child: _buildStatItem(hours, "HOURS LOGGED")),
                      ],
                    );
                  },
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildStandbyCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: Colors.lightBlue.withOpacity(0.3), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar, color: Colors.lightBlue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                "STANDBY: SECTOR CLEAR",
                style: TextStyle(color: Colors.lightBlue, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            "No urgent missions\ncurrently active.",
            style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentAlertCard(BuildContext context, dynamic incident) {
    final String id = incident['id'];
    final String category = incident['category'] ?? "EMERGENCY";
    final String desc = incident['description'] ?? "Assistance required";

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1616),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: TacticalColors.errorContainer.withOpacity(0.3), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: TacticalColors.onSurfaceVariant, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                "URGENT: ${category.toUpperCase()} NEEDED",
                style: TextStyle(color: TacticalColors.onSurfaceVariant, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            desc,
            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.near_me, color: Colors.white70, size: 14.sp),
              SizedBox(width: 6.w),
              Text(
                "Location coordinates attached",
                style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<TaskBloc>().add(AcceptMission(id)),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(color: TacticalColors.secondaryContainer, borderRadius: BorderRadius.circular(24.r)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.black, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          "Accept",
                          style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<AvailableTasksBloc>().add(DeclineTask(id)),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(color: TacticalColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(24.r)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel, color: Colors.white, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          "Decline",
                          style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicIncidentCard(dynamic incident) {
    final String category = incident['category'] ?? "GENERAL";
    final String reportedAt = _getTimeAgo(incident['reported_at']);

    IconData icon = Icons.warning;
    Color iconColor = TacticalColors.primaryContainer;
    Color iconBgColor = const Color(0xFF3A2015);
    String badgeText = "MEDIUM";
    Color badgeColor = Colors.white24;
    Color badgeTextColor = Colors.white70;

    if (category == 'MEDICAL') {
      icon = Icons.medical_services;
      iconColor = Colors.redAccent;
      iconBgColor = const Color(0xFF3A1A1A);
      badgeText = "CRITICAL";
      badgeColor = TacticalColors.errorContainer;
      badgeTextColor = Colors.white;
    } else if (category == 'FLOOD') {
      icon = Icons.waves;
      iconColor = Colors.lightBlue;
      iconBgColor = const Color(0xFF1A2A3A);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: _buildIncidentCard(
        title: "${category.replaceAll('_', ' ')} Alert",
        subtitle: "Sector coordinates • $reportedAt",
        icon: icon,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        badgeText: badgeText,
        badgeColor: badgeColor,
        badgeTextColor: badgeTextColor,
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        // UPDATED: Using a generic person icon instead of dummy URL
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: TacticalColors.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(color: TacticalColors.primaryContainer, width: 2.w),
          ),
          child: Icon(Icons.person, color: TacticalColors.primaryContainer, size: 20.sp),
        ),
        SizedBox(width: 16.w),
        Text(
          "ECHONET",
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: TacticalColors.primaryContainer,
          ),
        ),
        const Spacer(),
        Icon(Icons.notifications_none, color: TacticalColors.primaryContainer, size: 28.sp),
      ],
    );
  }

  Widget _buildStatusToggle() {
    return TacticalCard(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "QUICK STATUS",
                style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 2.0),
              ),
              SizedBox(height: 4.h),
              Text(
                "You are Available",
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Switch(value: _isAvailable, activeColor: TacticalColors.secondaryContainer, onChanged: (val) => setState(() => _isAvailable = val)),
        ],
      ),
    );
  }

  Widget _buildIncidentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String badgeText,
    required Color badgeColor,
    Color badgeTextColor = Colors.white,
  }) {
    return TacticalCard(
      padding: EdgeInsets.all(20.w),
      borderRadius: 28,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12.r)),
            child: Text(
              badgeText,
              style: TextStyle(color: badgeTextColor, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {Color color = TacticalColors.surfaceContainerLow}) {
    return TacticalCard(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      borderRadius: 24,
      color: color,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(color: TacticalColors.primary, fontSize: 24.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 9.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5, height: 1.2),
          ),
        ],
      ),
    );
  }
}
