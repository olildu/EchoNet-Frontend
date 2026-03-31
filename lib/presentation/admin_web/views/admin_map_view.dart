import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/presentation/theme/tactical_theme.dart';
import '../../../../logic/admin/admin_bloc.dart';
import '../../../../logic/map/location_tracking_bloc.dart';
import '../../../../logic/map/map_bloc.dart';

class AdminMapView extends StatefulWidget {
  const AdminMapView({super.key});

  @override
  State<AdminMapView> createState() => _AdminMapViewState();
}

class _AdminMapViewState extends State<AdminMapView> {
  @override
  void initState() {
    super.initState();
    // Connect to the WebSocket to receive live telemetry from volunteers
    context.read<LocationTrackingBloc>().add(StartTracking());
  }

  String _formatTime(String? isoDate) {
    if (isoDate == null) return "[--:--]";
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return "[${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}]";
    } catch (e) {
      return "[--:--]";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, adminState) {
        return BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
          builder: (context, trackingState) {
            // Stats derived from real backend states
            final activeIncidents = adminState.incidents.where((i) => i['status'] != 'RESOLVED').length;
            final deployedVolunteers = trackingState is PersonnelLocationsUpdated ? trackingState.personnel.length : 0;

            return LayoutBuilder(
              builder: (context, constraints) {
                // Determine the canvas size to correctly project GPS coordinates to pixels
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;

                return Stack(
                  children: [
                    // 1. TACTICAL MAP BACKGROUND
                    _buildTacticalBackground(),

                    // 2. LIVE INCIDENT PINS (REAL DATA)
                    ...adminState.incidents.map((inc) {
                      if (inc['latitude'] == null || inc['longitude'] == null) return const SizedBox();

                      // Converts GPS to Screen Pixels
                      final px = MapBloc.projectToPixels(inc['latitude'], inc['longitude'], screenWidth, screenHeight);
                      return Positioned(
                        top: px['top']! - 18.w, // Center the pin
                        left: px['left']! - 18.w,
                        child: _buildIncidentMarker(inc),
                      );
                    }).toList(),

                    // 3. LIVE PERSONNEL PINS (REAL DATA FROM WEBSOCKET)
                    if (trackingState is PersonnelLocationsUpdated)
                      ...trackingState.personnel.values.map((p) {
                        final px = MapBloc.projectToPixels(p['lat'], p['lng'], screenWidth, screenHeight);
                        return Positioned(top: px['top']! - 16.w, left: px['left']! - 16.w, child: _buildPersonnelMarker());
                      }).toList(),

                    // 4. STATS HUD (TOP RIGHT)
                    Positioned(
                      top: 32.h,
                      right: 32.w,
                      child: Column(
                        children: [_buildStatCard("ACTIVE INCIDENTS", activeIncidents.toString(), "+ 2%", TacticalColors.primaryContainer)],
                      ),
                    ),

                    // 5. LIVE TACTICAL FEED (BOTTOM LEFT)
                    Positioned(bottom: 32.h, left: 32.w, child: _buildTacticalFeed(adminState.incidents)),

                    // 6. TELEMETRY STREAM (BOTTOM RIGHT)
                    Positioned(bottom: 32.h, right: 32.w, child: _buildTelemetryHUD()),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildIncidentMarker(dynamic inc) {
    Color color = TacticalColors.primaryContainer;
    IconData icon = Icons.warning;

    // Change colors based on status priority
    if (inc['status'] == 'PENDING') {
      color = TacticalColors.errorContainer;
    } else if (inc['status'] == 'RESOLVED') {
      color = Colors.white24;
      icon = Icons.check_circle;
    }

    if (inc['category'] == 'MEDICAL') icon = Icons.medical_services;
    if (inc['category'] == 'FIRE') icon = Icons.local_fire_department;
    if (inc['category'] == 'FLOOD') icon = Icons.water_drop;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12.r)],
          ),
          child: Icon(icon, color: Colors.white, size: 18.sp),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4.r)),
          child: Text(
            inc['category'].toString().replaceAll('_', ' '),
            style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonnelMarker() {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: TacticalColors.secondaryContainer.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: TacticalColors.secondaryContainer),
      ),
      child: Center(
        child: Container(
          width: 8.w,
          height: 8.w,
          decoration: const BoxDecoration(color: TacticalColors.secondaryContainer, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildTacticalBackground() {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _TacticalGridPainter())),
        // Radar Circles Overlay
        Center(
          child: Container(
            width: 600.w,
            height: 600.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.03), width: 1),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 300.w,
            height: 300.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TacticalColors.primaryContainer.withOpacity(0.1), width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String status, Color accentColor) {
    return Container(
      width: 280.w,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: TacticalColors.surfaceContainerLow.withOpacity(0.8),
        border: Border(
          left: BorderSide(color: accentColor, width: 4.w),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white38, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.w900),
              ),
              Text(
                status,
                style: TextStyle(color: accentColor, fontSize: 10.sp, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTacticalFeed(List<dynamic> incidents) {
    final recent = incidents.take(4).toList();
    return Container(
      width: 400.w,
      decoration: BoxDecoration(
        color: TacticalColors.surfaceContainerLow.withOpacity(0.9),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: TacticalColors.surfaceContainerHigh.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "LIVE TACTICAL FEED",
                  style: TextStyle(color: TacticalColors.primaryContainer, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
                Row(
                  children: [
                    Container(width: 4.w, height: 4.w, color: TacticalColors.primaryContainer),
                    SizedBox(width: 2.w),
                    Container(width: 4.w, height: 4.w, color: TacticalColors.primaryContainer),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: recent.map((inc) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    children: [
                      Text(
                        _formatTime(inc['reported_at']),
                        style: TextStyle(color: Colors.white10, fontSize: 11.sp, fontFamily: 'Courier'),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "New ${inc['category']} Incident in System",
                          style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryHUD() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "TELEMETRY STREAM 08B-X",
          style: TextStyle(color: Colors.white10, fontSize: 9.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(12, Colors.white10),
            _buildBar(24, TacticalColors.primaryContainer),
            _buildBar(18, TacticalColors.primaryContainer),
            _buildBar(32, TacticalColors.secondaryContainer),
          ],
        ),
      ],
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      width: 4.w,
      height: height.h,
      color: color,
    );
  }
}

class _TacticalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0;

    double step = 60.w;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Corner Accents
    final accentPaint = Paint()
      ..color = TacticalColors.primaryContainer.withOpacity(0.2)
      ..strokeWidth = 2.0;

    canvas.drawLine(const Offset(40, 40), const Offset(80, 40), accentPaint);
    canvas.drawLine(const Offset(40, 40), const Offset(40, 80), accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
