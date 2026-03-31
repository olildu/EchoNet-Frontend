import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/presentation/theme/tactical_theme.dart';
import '../../../../logic/admin/admin_bloc.dart';

class AdminIncidentsScreen extends StatelessWidget {
  const AdminIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
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
    );
  }

  Widget _buildIncidentQueue(BuildContext context, AdminState state) {
    return Container(
      width: 380.w,
      decoration: BoxDecoration(
        color: TacticalColors.surfaceContainerLow,
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: state.incidents.length,
        itemBuilder: (context, index) {
          final inc = state.incidents[index];
          bool isSelected = state.selectedIncident?['id'] == inc['id'];
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
                  Text(
                    inc['category'],
                    style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIncidentDetails(BuildContext context, AdminState state) {
    if (state.selectedIncident == null) {
      return Center(
        child: Text(
          "SELECT AN INCIDENT TO TRIAGE",
          style: TextStyle(color: Colors.white24, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      );
    }

    final inc = state.selectedIncident!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(40.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SYSTEM_LIVE_TRIAGE",
            style: TextStyle(color: TacticalColors.primaryContainer, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 2.0),
          ),
          Text(
            "${inc['category']} OPERATION",
            style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 42.sp, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          SizedBox(height: 48.h),
          Text(
            '"${inc['description']}"',
            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 48.h),
          Text(
            "NEAREST_RESPONDER_MATCHING",
            style: TextStyle(color: Colors.white38, fontSize: 11.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          if (state.isLoading)
            const CircularProgressIndicator()
          else
            ...state.responders.map((volunteer) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(16.w),
                color: TacticalColors.surfaceContainerLow,
                child: Row(
                  children: [
                    Text(volunteer['name'], style: const TextStyle(color: Colors.white)),
                    const Spacer(),
                    Text("${volunteer['distance_meters']} M", style: const TextStyle(color: TacticalColors.primaryContainer)),
                    SizedBox(width: 16.w),
                    ElevatedButton(
                      onPressed: () => context.read<AdminBloc>().add(DispatchVolunteer(inc['id'], volunteer['id'])),
                      child: const Text("DISPATCH"),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
