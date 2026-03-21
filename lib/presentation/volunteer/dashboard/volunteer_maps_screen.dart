import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import '../../../logic/map/map_bloc.dart';
import '../../../logic/map/location_tracking_bloc.dart';
import '../../../data/session_manager.dart';

class VolunteerMapsScreen extends StatefulWidget {
  const VolunteerMapsScreen({super.key});

  @override
  State<VolunteerMapsScreen> createState() => _VolunteerMapsScreenState();
}

class _VolunteerMapsScreenState extends State<VolunteerMapsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Medical', 'Fire', 'Rescue', 'Flood'];
  Timer? _broadcastTimer;

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(FetchMapIntel());
    context.read<LocationTrackingBloc>().add(StartTracking());
    _startSimulatedBroadcasting();
  }

  @override
  void dispose() {
    _broadcastTimer?.cancel();
    super.dispose();
  }

  // Simulations for demonstration purposes
  void _startSimulatedBroadcasting() async {
    final userId = await SessionManager().getUserId();
    if (userId == null) return;

    _broadcastTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      double simLat = 26.9124 + (Random().nextDouble() * 0.002);
      double simLng = 75.7873 + (Random().nextDouble() * 0.002);
      context.read<LocationTrackingBloc>().add(BroadcastLocation(userId, simLat, simLng));
    });
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

          // LIVE INCIDENT PINS (Citizen Style)
          BlocBuilder<MapBloc, MapState>(
            builder: (context, state) {
              if (state is MapIntelLoaded) {
                // Apply filters locally
                final filteredList = _selectedFilter == 'All'
                    ? state.incidents
                    : state.incidents.where((i) => i['category'] == _selectedFilter.toUpperCase()).toList();

                return Stack(
                  children: filteredList.map((incident) {
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

          // LIVE PERSONNEL PINS (Volunteer Specific)
          BlocBuilder<LocationTrackingBloc, LocationTrackingState>(
            builder: (context, state) {
              if (state is PersonnelLocationsUpdated) {
                return Stack(
                  children: state.personnel.values.map((p) {
                    final pixels = MapBloc.projectToPixels(p['lat'], p['lng'], screenWidth, screenHeight);
                    return _buildUserLocationPin(top: pixels['top']!, left: pixels['left']!);
                  }).toList(),
                );
              }
              return const SizedBox();
            },
          ),

          // FOREGROUND UI
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                SizedBox(height: 16.h),
                _buildSearchBar(),
                SizedBox(height: 16.h),
                _buildFilters(),
                SizedBox(height: 16.h),

                // HUD
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _buildHUD(),
                ),

                const Spacer(),

                // FLOATING BUTTONS
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFloatingButton(Icons.my_location),
                        SizedBox(height: 12.h),
                        GestureDetector(onTap: () => context.read<MapBloc>().add(FetchMapIntel()), child: _buildFloatingButton(Icons.refresh)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // DYNAMIC TACTICAL CARD
                BlocBuilder<MapBloc, MapState>(
                  builder: (context, state) {
                    int count = 0;
                    if (state is MapIntelLoaded) {
                      count = _selectedFilter == 'All'
                          ? state.incidents.length
                          : state.incidents.where((i) => i['category'] == _selectedFilter.toUpperCase()).length;
                    }
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildActiveAlertCard(count),
                    );
                  },
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ICONS & COLORS ---
  IconData _getIcon(String category) => category == 'MEDICAL'
      ? Icons.medical_services
      : category == 'FIRE'
      ? Icons.local_fire_department
      : Icons.warning;

  Color _getColor(String category) => category == 'MEDICAL'
      ? Colors
            .redAccent // Red for medical matches citizen
      : category == 'FIRE'
      ? TacticalColors.primaryContainer
      : Colors.amber;

  // --- UI COMPONENTS ---
  Widget _buildMapBackground() {
    return Stack(
      children: [
        SizedBox.expand(
          child: CustomPaint(
            painter: _GridPainter(gridSize: 40.w, color: Colors.white.withOpacity(0.05)),
          ),
        ),
        // Concentric Radar Circle
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

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "FIELD OPS",
                style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 25.sp, fontWeight: FontWeight.w900, color: TacticalColors.primaryContainer),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: TacticalColors.secondaryContainer.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(color: TacticalColors.secondaryContainer, shape: BoxShape.circle),
                ),
                SizedBox(width: 6.w),
                Text(
                  "MESH ACTIVE",
                  style: TextStyle(color: TacticalColors.secondaryContainer, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(color: TacticalColors.surfaceContainerLow, borderRadius: BorderRadius.circular(20.r)),
        child: TextField(
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.white54, size: 20.sp),
            hintText: "Search sector or coordinate...",
            hintStyle: const TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          bool isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? TacticalColors.primaryContainer : TacticalColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
                "TRACKING PERSONNEL & INCIDENTS",
                style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Uses the Citizen Labeled Map Marker Design
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

  // Uses the Volunteer Pulse Radar Design for Personnel Tracking
  Widget _buildUserLocationPin({required double top, required double left}) {
    return Positioned(
      top: top - 32.w,
      left: left - 32.w,
      child: Container(
        width: 64.w,
        height: 64.w,
        decoration: BoxDecoration(
          color: TacticalColors.secondaryContainer.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: TacticalColors.secondaryContainer.withOpacity(0.5)),
        ),
        child: Center(
          child: Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: TacticalColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: TacticalColors.secondaryContainer, width: 4.w),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: TacticalColors.surfaceContainerHigh,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10.r)],
    ),
    child: Icon(icon, color: Colors.white, size: 20.sp),
  );

  Widget _buildActiveAlertCard(int incidentCount) {
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
                decoration: BoxDecoration(color: TacticalColors.errorContainer.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(Icons.radar, color: TacticalColors.errorContainer, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TACTICAL DEPLOYMENT",
                      style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 16.sp, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "$incidentCount Active incident(s) in sector",
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.w600),
                    ),
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
