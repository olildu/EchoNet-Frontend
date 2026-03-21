import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import '../../../logic/incident/incident_history_bloc.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _activeFilter = "ALL";

  @override
  void initState() {
    super.initState();
    context.read<IncidentHistoryBloc>().add(FetchMyIncidents());
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

  Widget _buildDynamicReportCard(dynamic incident) {
    final category = incident['category'] ?? 'GENERAL';
    final status = incident['status'] ?? 'PENDING';
    final description = incident['description'] ?? 'No description provided.';
    final timeAgo = _getTimeAgo(incident['reported_at']);

    IconData icon = Icons.warning;
    Color iconColor = TacticalColors.primary;
    String title = category;

    if (category == 'MEDICAL') {
      icon = Icons.medical_services;
    } else if (category == 'FLOOD') {
      icon = Icons.water_drop;
    } else if (category == 'FIRE') {
      icon = Icons.local_fire_department;
      iconColor = Colors.amber;
    }

    Color statusColor = TacticalColors.primaryContainer;
    String statusText = status;
    bool isDimmed = false;
    Widget leftFooter = _buildIconText(Icons.warning_amber_rounded, "PRIORITY: HIGH", Colors.white54);
    Widget rightFooter = _buildActionText("DETAILS >", TacticalColors.primary);

    if (status == 'ASSIGNED' || status == 'IN_PROGRESS') {
      statusColor = TacticalColors.secondaryContainer;
      statusText = "HELP EN ROUTE";
      leftFooter = _buildAvatarGroup();
    } else if (status == 'RESOLVED') {
      statusColor = Colors.white38;
      isDimmed = true;
      iconColor = Colors.white24;
      leftFooter = _buildIconText(Icons.check_circle, "CASE CLOSED", Colors.white38);
      rightFooter = _buildActionText("ARCHIVE  ↓", Colors.white38);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: _buildReportCard(
        icon: icon,
        iconColor: iconColor,
        title: title.replaceAll('_', ' '),
        locationTime: "MAPPED LOCATION • $timeAgo",
        statusText: statusText,
        statusColor: statusColor,
        description: description,
        isItalic: status == 'ASSIGNED',
        isDimmed: isDimmed,
        leftFooter: leftFooter,
        rightFooter: rightFooter,
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
            _buildAppBar(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<IncidentHistoryBloc, IncidentHistoryState>(
                builder: (context, state) {
                  if (state is IncidentHistoryLoading) {
                    return const Center(child: CircularProgressIndicator(color: TacticalColors.primaryContainer));
                  } else if (state is IncidentHistoryLoaded) {
                    List<dynamic> filteredList = state.incidents;
                    if (_activeFilter != "ALL") {
                      filteredList = state.incidents.where((i) => i['status'] == _activeFilter).toList();
                    }

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          if (filteredList.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text("No incidents match this filter.", style: TextStyle(color: Colors.white54)),
                            ),

                          ...filteredList.map((incident) => _buildDynamicReportCard(incident)),

                          _buildLiveFeedCard(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  } else if (state is IncidentHistoryFailure) {
                    return Center(
                      child: Text(state.error, style: const TextStyle(color: TacticalColors.errorContainer)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Text(
            "REPORTS",
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: TacticalColors.primary,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: TacticalColors.secondaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: TacticalColors.secondaryContainer, blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "NETWORK ACTIVE",
                style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ["ALL", "PENDING", "ASSIGNED", "RESOLVED"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          bool isActive = filter == _activeFilter;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? TacticalColors.primaryContainer : TacticalColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive
                    ? [BoxShadow(color: TacticalColors.primaryContainer.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Text(
                filter,
                style: TextStyle(color: isActive ? Colors.black : Colors.white60, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String locationTime,
    required String statusText,
    required Color statusColor,
    required String description,
    bool isItalic = false,
    bool isDimmed = false,
    required Widget leftFooter,
    required Widget rightFooter,
  }) {
    return TacticalCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      child: Opacity(
        opacity: isDimmed ? 0.5 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        locationTime,
                        style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                    boxShadow: [BoxShadow(color: statusColor.withOpacity(0.2), blurRadius: 12)],
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20)),
              child: Text(
                description,
                style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: isItalic ? FontStyle.italic : FontStyle.normal, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [leftFooter, rightFooter]),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveFeedCard() {
    return TacticalCard(
      padding: EdgeInsets.zero,
      borderRadius: 32,
      child: Stack(
        children: [
          // UPDATED: Replaced Unsplash image with tactical global feed icon
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: TacticalColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(32)),
              child: const Center(child: Icon(Icons.public, color: Colors.white10, size: 120)),
            ),
          ),
          Container(
            height: 180,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
            child: Stack(
              children: [
                Positioned(
                  top: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "03 Active",
                        style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 24, fontWeight: FontWeight.w900, color: TacticalColors.primary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "GLOBAL MONITORING",
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: TacticalColors.primary, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "LIVE SECTOR FEED",
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarGroup() {
    return Row(
      children: [
        _buildMiniAvatar(),
        Transform.translate(offset: const Offset(-8, 0), child: _buildMiniAvatar()),
      ],
    );
  }

  Widget _buildMiniAvatar() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: TacticalColors.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(color: TacticalColors.surfaceContainerLow, width: 2),
      ),
      child: const Icon(Icons.person, size: 12, color: Colors.white54),
    );
  }

  Widget _buildIconText(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
      ],
    );
  }

  Widget _buildActionText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/report_emergency');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 8),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: TacticalColors.sosGradient,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: TacticalColors.primaryContainer.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 32),
      ),
    );
  }
}
