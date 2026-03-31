import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/presentation/theme/tactical_theme.dart';
import '../../../../logic/admin/admin_bloc.dart';

// 1. CHANGE TO STATEFUL WIDGET
class AdminPersonnelView extends StatefulWidget {
  const AdminPersonnelView({super.key});

  @override
  State<AdminPersonnelView> createState() => _AdminPersonnelViewState();
}

class _AdminPersonnelViewState extends State<AdminPersonnelView> {
  // 2. TRIGGER THE FETCH EVENT WHEN THE SCREEN LOADS
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadPersonnel());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.isLoading && state.personnel.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: TacticalColors.primaryContainer));
        }

        return Padding(
          padding: EdgeInsets.all(40.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "VOLUNTEER FLEET",
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: TacticalColors.primaryContainer),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      "INVITE NGO",
                      style: TextStyle(color: TacticalColors.primaryContainer, fontSize: 11.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // TABLE HEADER
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                color: TacticalColors.surfaceContainerHigh.withOpacity(0.5),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _headerCell("CALLSIGN / NAME")),
                    Expanded(flex: 2, child: _headerCell("STATUS")),
                    Expanded(flex: 4, child: _headerCell("SKILLS")),
                    Expanded(flex: 2, child: _headerCell("COMPLETED")),
                    Expanded(flex: 2, child: _headerCell("ACTIONS", textAlign: TextAlign.right)),
                  ],
                ),
              ),

              // TABLE BODY
              Expanded(
                child: ListView.separated(
                  itemCount: state.personnel.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  itemBuilder: (context, index) {
                    final p = state.personnel[index];
                    return _buildPersonnelRow(p);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerCell(String text, {TextAlign textAlign = TextAlign.left}) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(color: Colors.white24, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
    );
  }

  Widget _buildPersonnelRow(dynamic p) {
    final bool isActive = p['is_active'] ?? false;
    final List<dynamic> skills = p['skills'] ?? [];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Row(
        children: [
          // Name / Callsign
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['full_name'],
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  p['phone'],
                  style: TextStyle(color: Colors.white24, fontSize: 11.sp, fontFamily: 'Courier'),
                ),
              ],
            ),
          ),

          // Status Pill
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isActive ? TacticalColors.secondaryContainer.withOpacity(0.1) : Colors.white10,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: isActive ? TacticalColors.secondaryContainer.withOpacity(0.5) : Colors.white24),
                  ),
                  child: Text(
                    isActive ? "AVAILABLE" : "OFFLINE",
                    style: TextStyle(
                      color: isActive ? TacticalColors.secondaryContainer : Colors.white38,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Skills Chips
          Expanded(
            flex: 4,
            child: Wrap(
              spacing: 8.w,
              children: skills
                  .take(3)
                  .map(
                    (s) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4.r)),
                      child: Text(
                        s.toString(),
                        style: TextStyle(color: Colors.white54, fontSize: 9.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Tasks Completed
          Expanded(
            flex: 2,
            child: Text(
              "${p['tasks_completed']} MISSIONS",
              style: TextStyle(color: TacticalColors.primaryContainer, fontSize: 12.sp, fontWeight: FontWeight.w900, fontFamily: 'Courier'),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.contact_emergency, color: Colors.white38, size: 18.sp),
                SizedBox(width: 16.w),
                Icon(Icons.more_vert, color: Colors.white38, size: 18.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
