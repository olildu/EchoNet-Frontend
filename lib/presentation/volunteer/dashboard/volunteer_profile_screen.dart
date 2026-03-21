import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/presentation/widgets/tactical_button.dart';
import '../../../logic/profile/profile_bloc.dart';
import '../../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import '../../../data/session_manager.dart';

class VolunteerProfileScreen extends StatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  State<VolunteerProfileScreen> createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  bool _isAvailable = true;
  String _userName = "Responder";

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final userId = await SessionManager().getUserId();
    final name = await SessionManager().getFullName();

    if (mounted) {
      if (name != null) setState(() => _userName = name);
      if (userId != null) context.read<ProfileBloc>().add(FetchProfileStats(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          // Default fallbacks while loading
          String missions = "0";
          String hours = "0";
          String phone = "Awaiting Sync...";
          String age = "Unknown";
          List<String> skills = ["SYNCING SKILLS..."];

          // Extract dynamic data from the backend payload
          if (state is ProfileLoaded) {
            missions = state.stats['tasks_completed']?.toString() ?? "0";
            hours = state.stats['hours_logged']?.toString() ?? "0";
            if (state.stats['phone'] != null) phone = state.stats['phone'];
            if (state.stats['age'] != null) age = state.stats['age'].toString();
            if (state.stats['skills'] != null) {
              skills = List<String>.from(state.stats['skills']);
            }
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(missions, hours),
                SizedBox(height: 24.h),
                _buildReadinessToggle(),
                SizedBox(height: 32.h),
                _buildSectionTitle("PERSONNEL RECORDS"),
                SizedBox(height: 16.h),
                _buildPersonnelRecords(phone, age),
                SizedBox(height: 32.h),
                _buildSectionTitle("DEPLOYMENT SKILLS"),
                SizedBox(height: 16.h),
                _buildSkillsWrap(skills),
                SizedBox(height: 32.h),
                _buildSectionTitle("AFFILIATION"),
                SizedBox(height: 16.h),
                _buildAffiliationCard(),
                SizedBox(height: 40.h),
                _buildActionButtons(),
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String missions, String hours) {
    return TacticalCard(
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
      borderRadius: 32,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // UPDATED: Using a generic person icon instead of dummy URL
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: TacticalColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(color: TacticalColors.primaryContainer, width: 3.w),
                ),
                child: Icon(Icons.person, color: TacticalColors.primaryContainer, size: 50.sp),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 14.r,
                  backgroundColor: TacticalColors.secondaryContainer,
                  child: Icon(Icons.verified, color: Colors.black, size: 14.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            _userName,
            style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            "CERTIFIED VOLUNTEER",
            style: TextStyle(color: TacticalColors.primaryContainer, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatPill("MISSION COUNT", missions),
              SizedBox(width: 12.w),
              _buildStatPill("HOURS LOGGED", hours),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(color: TacticalColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(24.r)),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white54, fontSize: 9.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(color: TacticalColors.secondaryContainer, fontSize: 20.sp, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessToggle() {
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
                "Emergency Readiness",
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                _isAvailable ? "Available for immediate response" : "Currently off-duty",
                style: TextStyle(color: Colors.white54, fontSize: 12.sp),
              ),
            ],
          ),
          Switch(
            value: _isAvailable,
            activeColor: TacticalColors.secondaryContainer,
            activeTrackColor: TacticalColors.secondaryContainer.withOpacity(0.3),
            inactiveTrackColor: Colors.white10,
            onChanged: (val) => setState(() => _isAvailable = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(color: TacticalColors.primary, fontSize: 12.sp, fontWeight: FontWeight.w900, letterSpacing: 2.0),
    );
  }

  Widget _buildPersonnelRecords(String phone, String age) {
    return TacticalCard(
      padding: EdgeInsets.all(24.w),
      borderRadius: 32,
      child: Column(
        children: [
          _buildRecordRow(Icons.person, "FULL NAME", _userName),
          SizedBox(height: 24.h),
          _buildRecordRow(Icons.phone, "TACTICAL COMM LINE", phone),
          SizedBox(height: 24.h),
          _buildRecordRow(Icons.calendar_month, "PERSONNEL AGE", "$age Standard Years"),
        ],
      ),
    );
  }

  Widget _buildRecordRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: TacticalColors.primaryContainer, size: 20.sp),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.white38, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsWrap(List<String> skills) {
    if (skills.isEmpty) {
      skills = ["GENERAL VOLUNTEER"];
    }

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: skills.map((skill) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: TacticalColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: TacticalColors.primaryContainer.withOpacity(0.3)),
          ),
          child: Text(
            skill.replaceAll('_', ' '), // Format enums nicely
            style: TextStyle(color: TacticalColors.primary, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAffiliationCard() {
    return TacticalCard(
      padding: EdgeInsets.all(20.w),
      borderRadius: 28,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(color: TacticalColors.surfaceContainerHighest, shape: BoxShape.circle),
            child: Icon(Icons.group, color: TacticalColors.primaryContainer, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Independent Volunteer",
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Verified through Global Response Registry",
                  style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        TacticalButton(
          text: "TERMINATE SESSION",
          icon: Icons.logout,
          isGradient: false,
          textColor: TacticalColors.primary,
          onPressed: () async {
            await SessionManager().clearSession();
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
          },
        ),
      ],
    );
  }
}
