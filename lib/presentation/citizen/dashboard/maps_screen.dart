import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import '../../../logic/map/map_bloc.dart';
import '../../../logic/map/location_tracking_bloc.dart'; // NEW

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(FetchMapIntel());
    context.read<LocationTrackingBloc>().add(StartTracking()); // NEW
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: Stack(
        children: [
          _buildMapBackground(),

          // LIVE INCIDENT PINS
          BlocBuilder<MapBloc, MapState>(
            builder: (context, state) {
              if (state is MapIntelLoaded) {
                return Stack(
                  children: state.incidents.map((incident) {
                    final pixels = MapBloc.projectToPixels(incident['latitude'] ?? 0.0, incident['longitude'] ?? 0.0, screenWidth, screenHeight);
                    return _buildMapMarker(
                      top: pixels['top']!,
                      left: pixels['left']!,
                      icon: _getIcon(incident['category']),
                      color: _getColor(incident['category']),
                      label: incident['category'].toString().replaceAll('_', ' '),
                    );
                  }).toList(),
                );
              }
              return const SizedBox();
            },
          ),

          // LIVE PERSONNEL TRACKING (NEW)
          BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
            builder: (context, state) {
              if (state is PersonnelLocationsUpdated) {
                return Stack(
                  children: state.personnel.values.map((p) {
                    final pixels = MapBloc.projectToPixels(p['lat'], p['lng'], screenWidth, screenHeight);
                    return Positioned(
                      top: pixels['top']!,
                      left: pixels['left']!,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: TacticalColors.secondaryContainer,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: TacticalColors.secondaryContainer.withOpacity(0.5), blurRadius: 10.r, spreadRadius: 2.r)],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
              return const SizedBox();
            },
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MAP OVERVIEW",
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: TacticalColors.primaryContainer,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Align(alignment: Alignment.topLeft, child: _buildHUD()),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFloatingButton(Icons.my_location),
                        SizedBox(height: 12.h),
                        GestureDetector(onTap: () => context.read<MapBloc>().add(FetchMapIntel()), child: _buildFloatingButton(Icons.refresh)),
                      ],
                    ),
                  ),
                  _buildActiveAlertCard(),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- [Helpers from original remain the same] ---
  IconData _getIcon(String category) => category == 'MEDICAL'
      ? Icons.medical_services
      : category == 'FIRE'
      ? Icons.local_fire_department
      : Icons.warning;
  Color _getColor(String category) => category == 'MEDICAL'
      ? Colors.redAccent
      : category == 'FIRE'
      ? TacticalColors.primaryContainer
      : Colors.amber;

  Widget _buildMapBackground() {
    return Stack(
      children: [
        SizedBox.expand(
          child: CustomPaint(
            painter: _GridPainter(gridSize: 40.w, color: Colors.white.withOpacity(0.05)),
          ),
        ),
        Positioned(
          top: 80.h,
          left: -180.w,
          child: Container(
            width: 400.w,
            height: 400.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TacticalColors.primaryContainer.withOpacity(0.4), width: 1.5.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHUD() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TacticalCard(
          padding: EdgeInsets.all(16.w),
          color: TacticalColors.surfaceContainerLow.withOpacity(0.9),
          borderRadius: 24,
          leftBorder: BorderSide(color: TacticalColors.primaryContainer, width: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SECTOR INTEL",
                style: TextStyle(color: Colors.white38, fontSize: 9.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              SizedBox(height: 4.h),
              Text(
                "SCANNING ENCRYPTED MESH...",
                style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapMarker({required double top, required double left, required IconData icon, required Color color, required String label}) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12.r)],
            ),
            child: Icon(icon, color: Colors.black, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12.r)),
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: TacticalColors.surfaceContainerLow,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: Icon(icon, color: Colors.white54, size: 20.sp),
  );

  Widget _buildActiveAlertCard() {
    return TacticalCard(
      padding: EdgeInsets.all(20.w),
      borderRadius: 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                child: Icon(Icons.radar, color: TacticalColors.primaryContainer, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TACTICAL FEED",
                      style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                    Text("Tap pins to view incident details"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double gridSize;
  final Color color;
  _GridPainter({required this.gridSize, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.width; i += gridSize) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += gridSize) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
