import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_app_bar.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import 'package:frontend/presentation/widgets/tactical_button.dart';
import '../../../logic/task/task_details_bloc.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskDetailsBloc>().add(LoadActiveTask());
  }

  Future<void> _launchNavigation(double lat, double lng) async {
    final googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final appleUrl = Uri.parse('https://maps.apple.com/?q=$lat,$lng');

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleUrl)) {
      await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
    }
  }

  String _getTimeAgo(String? isoDate) {
    if (isoDate == null) return "JUST NOW";
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      return "${diff.inHours}h ago";
    } catch (e) {
      return "RECENT";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: _buildAppBar(),
      body: BlocBuilder<TaskDetailsBloc, TaskDetailsState>(
        builder: (context, state) {
          if (state is TaskDetailsLoading) return const Center(child: CircularProgressIndicator(color: TacticalColors.primaryContainer));

          if (state is TaskDetailsEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: TacticalColors.primaryContainer.withOpacity(0.05),
                          border: Border.all(color: TacticalColors.primaryContainer.withOpacity(0.1), width: 2),
                        ),
                      ),
                      Icon(Icons.radar, color: TacticalColors.primaryContainer, size: 60.sp),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  Text(
                    "SYSTEM STANDBY",
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "No active mission has been assigned to your\npersonnel profile at this time.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 14.sp, height: 1.5),
                  ),
                  SizedBox(height: 48.h),

                  TacticalCard(
                    padding: EdgeInsets.all(20.w),
                    color: TacticalColors.surfaceContainerHigh,
                    child: Column(
                      children: [
                        _buildInstructionsRow(Icons.check_circle_outline, "Accept a mission from the HOME dashboard"),
                        SizedBox(height: 16.h),
                        _buildInstructionsRow(Icons.map_outlined, "Check the MAP for nearby incidents"),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            );
          }

          if (state is TaskDetailsError)
            return Center(
              child: Text(state.error, style: const TextStyle(color: TacticalColors.errorContainer)),
            );

          if (state is TaskDetailsLoaded) {
            final task = state.data;
            final incident = task['incident'];
            final status = task['status'];
            final String? evidenceUrl = incident['evidence_url'];
            final double lat = incident['latitude'] ?? 0.0;
            final double lng = incident['longitude'] ?? 0.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(incident['category'], incident['reported_at']),
                  SizedBox(height: 16.h),
                  _buildPhotoCard(evidenceUrl),
                  SizedBox(height: 16.h),
                  _buildRequirementCard(incident['description']),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Expanded(flex: 6, child: _buildStatusCard(status))],
                  ),
                  SizedBox(height: 16.h),
                  _buildMapCard(lat, lng), // Map Widget Updated
                  SizedBox(height: 16.h),
                  _buildLifecycleButton(status, lat, lng),
                  SizedBox(height: 16.h),
                  _buildActionButtons(status),
                  SizedBox(height: 40.h),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return TacticalAppBar(
      title: "Task Details",
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white70),
          onPressed: () => context.read<TaskDetailsBloc>().add(LoadActiveTask()),
        ),
      ],
    );
  }

  Widget _buildInstructionsRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: TacticalColors.secondaryContainer, size: 18.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildLifecycleButton(String status, double lat, double lng) {
    String text = "NAVIGATE TO SITE";
    String nextStatus = "EN_ROUTE";
    IconData icon = Icons.navigation;

    if (status == "ACCEPTED") {
      text = "START MISSION (NAVIGATE)";
      nextStatus = "EN_ROUTE";
    } else if (status == "EN_ROUTE") {
      text = "ARRIVED ON SCENE";
      nextStatus = "ON_SCENE";
      icon = Icons.location_on;
    } else if (status == "ON_SCENE") {
      text = "MARK AS COMPLETED";
      nextStatus = "COMPLETED";
      icon = Icons.check_circle;
    }

    return TacticalButton(
      text: text,
      icon: icon,
      isGradient: status == "ON_SCENE" || status == "ACCEPTED",
      textColor: status == "ON_SCENE" || status == "ACCEPTED" ? Colors.black : Colors.white,
      backgroundColor: TacticalColors.surfaceContainerHighest,
      onPressed: () async {
        if (status == "ACCEPTED") {
          await _launchNavigation(lat, lng);
        }
        context.read<TaskDetailsBloc>().add(UpdateStatus(nextStatus));
      },
    );
  }

  Widget _buildHeaderCard(String category, String time) {
    return TacticalCard(
      padding: EdgeInsets.all(20.w),
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PRIORITY STATUS",
                style: TextStyle(color: TacticalColors.primary, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: TacticalColors.errorContainer, borderRadius: BorderRadius.circular(12.r)),
                child: Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "HIGH",
                      style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "${category.replaceAll('_', ' ')} OPERATION",
            style: TextStyle(fontFamily: 'Space Grotesk', color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.location_on, color: TacticalColors.primary, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                "Sector Alpha",
                style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 24.w),
              Icon(Icons.access_time, color: Colors.white54, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                _getTimeAgo(time),
                style: TextStyle(color: Colors.white54, fontSize: 13.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: TacticalColors.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: Colors.white10, width: 1.5.w),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              "NO VISUAL EVIDENCE PROVIDED",
              style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 2.0),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(28.r)),
          ),
          Positioned(
            bottom: 16.h,
            left: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12.r)),
              child: Text(
                "FIELD INTELLIGENCE PHOTO",
                style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard(String desc) {
    return TacticalCard(
      padding: EdgeInsets.all(20.w),
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TACTICAL REQUIREMENT",
            style: TextStyle(color: TacticalColors.primary, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          SizedBox(height: 12.h),
          Text(
            desc,
            style: TextStyle(color: Colors.white, fontSize: 16.sp, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String currentStatus) {
    bool enRoute = currentStatus == "EN_ROUTE" || currentStatus == "ON_SCENE";
    bool onScene = currentStatus == "ON_SCENE";
    return TacticalCard(
      padding: EdgeInsets.all(16.w),
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "MISSION STATUS",
            style: TextStyle(color: Colors.white54, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          SizedBox(height: 16.h),
          _buildStatusStep(icon: Icons.check_circle, color: TacticalColors.secondaryContainer, label: "REPORTED", isCompleted: true),
          _buildStatusLine(TacticalColors.primaryContainer),
          _buildStatusStep(icon: Icons.radar, color: TacticalColors.primaryContainer, label: "ACCEPTED", isCompleted: true),
          _buildStatusLine(enRoute ? TacticalColors.primaryContainer : Colors.white10),
          _buildStatusStep(
            icon: Icons.local_shipping,
            color: enRoute ? TacticalColors.primaryContainer : Colors.white24,
            label: "EN ROUTE",
            isCompleted: enRoute,
          ),
          _buildStatusLine(onScene ? TacticalColors.primaryContainer : Colors.white10),
          _buildStatusStep(
            icon: Icons.home_repair_service,
            color: onScene ? TacticalColors.primaryContainer : Colors.white24,
            label: "ON SCENE",
            isCompleted: onScene,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep({required IconData icon, required Color color, required String label, required bool isCompleted}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(color: isCompleted ? color : Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
      ],
    );
  }

  Widget _buildStatusLine(Color color) {
    return Container(
      margin: EdgeInsets.only(left: 9.w, top: 4.h, bottom: 4.h),
      width: 2.w,
      height: 16.h,
      color: color,
    );
  }

  Widget _buildMapCard(double lat, double lng) {
    return GestureDetector(
      onTap: () => _launchNavigation(lat, lng),
      child: Container(
        width: double.infinity,
        height: 220.h,
        decoration: BoxDecoration(
          color: TacticalColors.surfaceContainerHighest, // UPDATED: Solid background
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // UPDATED: Replaced Unsplash with Map Icon background
            Icon(Icons.map, color: Colors.white10, size: 100.sp),
            Icon(Icons.location_on, color: TacticalColors.primaryContainer, size: 40.sp),
            Positioned(
              bottom: 16.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16.r)),
                child: Text(
                  "${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E",
                  style: TextStyle(color: TacticalColors.primary, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: TacticalButton(
            text: "ABORT",
            isGradient: false,
            textColor: Colors.white,
            backgroundColor: TacticalColors.surfaceContainerLow,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 6,
          child: TacticalButton(
            text: "OPEN CHAT",
            icon: Icons.chat_bubble_outline,
            isGradient: true,
            textColor: Colors.black,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Switch to CHAT tab for secure mission comms")));
            },
          ),
        ),
      ],
    );
  }
}
