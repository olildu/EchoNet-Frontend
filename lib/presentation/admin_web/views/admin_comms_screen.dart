import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';

class AdminCommsScreen extends StatefulWidget {
  const AdminCommsScreen({super.key});

  @override
  State<AdminCommsScreen> createState() => _AdminCommsScreenState();
}

class _AdminCommsScreenState extends State<AdminCommsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. LEFT SIDEBAR ---
  Widget _buildSidebar() {
    return Container(
      width: 80.w,
      color: TacticalColors.surfaceContainerLow,
      child: Column(
        children: [
          SizedBox(height: 24.h),
          Icon(Icons.emergency, color: TacticalColors.primaryContainer, size: 36.sp),
          SizedBox(height: 48.h),
          _buildSidebarIcon(Icons.radar, isActive: false),
          _buildSidebarIcon(Icons.report, isActive: false),
          _buildSidebarIcon(Icons.people, isActive: false),
          // ACTIVE ITEM: Communications
          _buildSidebarIcon(Icons.chat, isActive: true),
          _buildSidebarIcon(Icons.analytics, isActive: false),
        ],
      ),
    );
  }

  Widget _buildSidebarIcon(IconData icon, {required bool isActive}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: isActive ? TacticalColors.surfaceContainerHighest : Colors.transparent,
        border: isActive
            ? Border(
                left: BorderSide(color: TacticalColors.primaryContainer, width: 4.w),
              )
            : null,
      ),
      child: Icon(icon, color: isActive ? TacticalColors.primaryContainer : Colors.white38, size: 28.sp),
    );
  }

  // --- 2. TOP BAR ---
  Widget _buildTopBar() {
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      decoration: BoxDecoration(
        color: TacticalColors.background,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // System Status
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(color: TacticalColors.secondaryContainer, shape: BoxShape.circle),
              ),
              SizedBox(width: 12.w),
              Text(
                "NETWORK: ACTIVE",
                style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 2.0),
              ),
            ],
          ),
          // Search & Profile
          Row(
            children: [
              Container(
                width: 300.w,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(color: TacticalColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8.r)),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.white38, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        decoration: const InputDecoration(
                          hintText: "Search incidents, callsigns...",
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.w),
              CircleAvatar(
                radius: 20.r,
                backgroundColor: TacticalColors.surfaceContainerHighest,
                child: Icon(Icons.shield, color: TacticalColors.primaryContainer, size: 20.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. MAIN CONTENT (TABS) ---
  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TACTICAL COMMUNICATIONS",
            style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
          ),
          SizedBox(height: 24.h),
          TabBar(
            controller: _tabController,
            indicatorColor: TacticalColors.primaryContainer,
            labelColor: TacticalColors.primaryContainer,
            unselectedLabelColor: Colors.white38,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            tabs: const [
              Tab(text: "GLOBAL BROADCAST"),
              Tab(text: "INCIDENT OVERWATCH"),
            ],
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: TabBarView(controller: _tabController, children: [_buildGlobalBroadcastTab(), _buildIncidentOverwatchTab()]),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: GLOBAL BROADCAST ---
  String _threatLevel = 'Advisory';

  Widget _buildGlobalBroadcastTab() {
    return TacticalCard(
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("SELECT SECTOR / REGION", style: _labelStyle()),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(color: TacticalColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8.r)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'ALL SECTORS',
                dropdownColor: TacticalColors.surfaceContainerHighest,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                isExpanded: true,
                items: ['ALL SECTORS', 'Sector 1-A', 'Sector 4-B'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {},
              ),
            ),
          ),
          SizedBox(height: 32.h),

          Text("THREAT LEVEL", style: _labelStyle()),
          SizedBox(height: 8.h),
          Row(
            children: ['Advisory', 'Warning', 'Critical'].map((level) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(
                    level,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                  value: level,
                  groupValue: _threatLevel,
                  activeColor: level == 'Critical' ? TacticalColors.errorContainer : TacticalColors.primaryContainer,
                  onChanged: (val) => setState(() => _threatLevel = val!),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 32.h),

          Text("BROADCAST MESSAGE", style: _labelStyle()),
          SizedBox(height: 8.h),
          TextField(
            maxLength: 160,
            maxLines: 4,
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
            decoration: InputDecoration(
              filled: true,
              fillColor: TacticalColors.surfaceContainerHighest,
              counterStyle: TextStyle(color: Colors.white54, fontSize: 12.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
            ),
          ),
          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 60.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TacticalColors.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () {},
              child: Text(
                "INITIATE EMERGENCY BROADCAST",
                style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w900, letterSpacing: 2.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: INCIDENT OVERWATCH ---
  Widget _buildIncidentOverwatchTab() {
    return Row(
      children: [
        // Left Column: Chat Rooms
        Expanded(
          flex: 3,
          child: TacticalCard(
            padding: EdgeInsets.zero,
            child: ListView(
              children: [
                _buildChatRoomTile("INC-882: Structural Fire", isActive: true, unread: 2),
                _buildChatRoomTile("INC-883: Flood Extraction", isActive: false, unread: 0),
                _buildChatRoomTile("INC-884: Medevac Required", isActive: false, unread: 0),
              ],
            ),
          ),
        ),
        SizedBox(width: 24.w),
        // Right Column: Transcript
        Expanded(
          flex: 7,
          child: TacticalCard(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                // Chat Header
                Row(
                  children: [
                    Icon(Icons.local_fire_department, color: TacticalColors.primaryContainer, size: 24.sp),
                    SizedBox(width: 12.w),
                    Text(
                      "INC-882: Structural Fire",
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Divider(color: Colors.white10, height: 32.h),

                // Chat Messages
                Expanded(
                  child: ListView(
                    children: [
                      _buildChatBubble(text: "We are on scene. Fire is spreading to the west wing.", isSystem: false, sender: "Vol. Shepard"),
                      _buildChatBubble(text: "Copy that. Pushing structural blueprints to your HUD now.", isSystem: true, sender: "OVERWATCH"),
                      _buildChatBubble(text: "Received. Initiating breach.", isSystem: false, sender: "Vol. Shepard"),
                    ],
                  ),
                ),

                // Input Area
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: "Send tactical update...",
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: TacticalColors.surfaceContainerHighest,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(color: TacticalColors.primaryContainer, borderRadius: BorderRadius.circular(8.r)),
                      child: Icon(Icons.send, color: Colors.black, size: 20.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatRoomTile(String title, {required bool isActive, required int unread}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isActive ? TacticalColors.surfaceContainerHighest : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          if (unread > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(color: TacticalColors.primaryContainer, borderRadius: BorderRadius.circular(12.r)),
              child: Text(
                unread.toString(),
                style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatBubble({required String text, required bool isSystem, required String sender}) {
    return Align(
      alignment: isSystem ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        constraints: BoxConstraints(maxWidth: 500.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSystem ? TacticalColors.background : TacticalColors.surfaceContainerHighest,
          border: isSystem ? Border.all(color: TacticalColors.primaryContainer) : null,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(color: isSystem ? TacticalColors.primaryContainer : Colors.white54, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
            ),
            SizedBox(height: 8.h),
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 14.sp, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle() => TextStyle(color: Colors.white54, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5);
}
