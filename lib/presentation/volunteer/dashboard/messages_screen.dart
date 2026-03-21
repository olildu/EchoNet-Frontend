import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_app_bar.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import 'package:frontend/presentation/widgets/tactical_button.dart';
import 'package:frontend/presentation/widgets/tactical_text_field.dart';
import '../../../logic/chat/chat_bloc.dart';
import '../../../logic/task/task_details_bloc.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String? _currentIncidentId;

  @override
  void initState() {
    super.initState();
    context.read<TaskDetailsBloc>().add(LoadActiveTask());
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

  void _showCommsDialog(BuildContext context, String incidentId) {
    final TextEditingController msgController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: TacticalCard(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "TRANSMIT MESSAGE",
                style: TextStyle(color: TacticalColors.primaryContainer, fontSize: 12.sp, fontWeight: FontWeight.w900, letterSpacing: 2.0),
              ),
              SizedBox(height: 24.h),
              TacticalTextField(label: "MESSAGE PAYLOAD", hint: "Enter tactical update...", icon: Icons.chat, controller: msgController, maxLines: 3),
              SizedBox(height: 24.h),
              TacticalButton(
                text: "SEND TRANSMISSION",
                icon: Icons.send,
                isGradient: true,
                onPressed: () {
                  if (msgController.text.isNotEmpty) {
                    context.read<ChatBloc>().add(SendMessage(incidentId, msgController.text));
                    Navigator.pop(context);
                  }
                },
              ),
              SizedBox(height: 12.h),
              TacticalButton(
                text: "CANCEL",
                isGradient: false,
                textColor: Colors.white54,
                backgroundColor: Colors.transparent,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskDetailsBloc, TaskDetailsState>(
      listener: (context, state) {
        if (state is TaskDetailsLoaded) {
          final id = state.data['incident']['id'];
          if (_currentIncidentId != id) {
            setState(() => _currentIncidentId = id);
            context.read<ChatBloc>().add(FetchMessages(id));
          }
        }
      },
      child: Scaffold(
        backgroundColor: TacticalColors.background,
        appBar: _buildAppBar(),
        body: BlocBuilder<TaskDetailsBloc, TaskDetailsState>(
          builder: (context, taskState) {
            if (taskState is TaskDetailsEmpty) {
              return Center(
                child: Text(
                  "NO ACTIVE MISSION FOUND\nSECURE CHANNEL OFFLINE",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontSize: 12.sp, letterSpacing: 2.0),
                ),
              );
            }

            if (taskState is TaskDetailsLoaded) {
              final incident = taskState.data['incident'];

              return Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel("ACTIVE EMERGENCY", TacticalColors.primaryContainer),
                        SizedBox(height: 16.h),
                        _buildActiveEmergencyCard(context, incident),
                        SizedBox(height: 40.h),
                        _buildSectionLabel("COMMUNICATION LOGS", TacticalColors.primary),
                        SizedBox(height: 16.h),
                        _buildMessageLogs(),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                  Positioned(bottom: 16.h, left: 24.w, child: _buildStatusOverlay()),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator(color: TacticalColors.primaryContainer));
          },
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 2.0),
        ),
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }

  Widget _buildMessageLogs() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) return const Center(child: CircularProgressIndicator());
        if (state is ChatLoaded) {
          if (state.messages.isEmpty) {
            return Text(
              "No secure logs found for this sector.",
              style: TextStyle(color: Colors.white54, fontSize: 13.sp),
            );
          }
          return Column(
            children: state.messages.reversed.map((msg) {
              final senderSuffix = msg['sender_id'].toString().substring(0, 4);
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildLogItem(name: "Operator #$senderSuffix", subtitle: msg['content'] ?? "", time: _getTimeAgo(msg['timestamp'])),
              );
            }).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return TacticalAppBar(
      title: "MESSAGES",
      showBackButton: false,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: TacticalColors.primary, size: 20.sp),
          onPressed: () {
            if (_currentIncidentId != null) context.read<ChatBloc>().add(FetchMessages(_currentIncidentId!));
          },
        ),
      ],
    );
  }

  Widget _buildActiveEmergencyCard(BuildContext context, dynamic incident) {
    return TacticalCard(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // UPDATED: Replaced dummy network image with emergency icon
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: TacticalColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(color: TacticalColors.secondaryContainer, width: 2.w),
                    ),
                    child: Icon(Icons.emergency, color: TacticalColors.secondaryContainer, size: 28.sp),
                  ),
                  Positioned(
                    bottom: -8.h,
                    left: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(color: TacticalColors.secondaryContainer, borderRadius: BorderRadius.circular(8.r)),
                      child: Text(
                        "LIVE",
                        style: TextStyle(color: Colors.black, fontSize: 8.sp, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${incident['category']}\nOperation".replaceAll('_', ' '),
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "ACTIVE SECTOR",
                      style: TextStyle(color: TacticalColors.primary, fontSize: 12.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(color: TacticalColors.secondaryContainer, borderRadius: BorderRadius.circular(12.r)),
                child: Text(
                  "ACTIVE",
                  style: TextStyle(color: Colors.black, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              String latestMsg = "Awaiting secure comms...";
              String latestTime = "";
              if (state is ChatLoaded && state.messages.isNotEmpty) {
                latestMsg = "\"${state.messages.last['content']}\"";
                latestTime = _getTimeAgo(state.messages.last['timestamp']);
              }
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(20.r)),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble, color: TacticalColors.primaryContainer, size: 20.sp),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        latestMsg,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      latestTime,
                      style: TextStyle(color: TacticalColors.primary, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: TacticalButton(
                  text: "OPEN COMMS",
                  isGradient: true,
                  textColor: Colors.black,
                  onPressed: () => _showCommsDialog(context, incident['id']),
                ),
              ),
              SizedBox(width: 16.w),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: const BoxDecoration(color: TacticalColors.surfaceContainerHighest, shape: BoxShape.circle),
                child: Icon(Icons.location_on, color: Colors.white, size: 20.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem({required String name, required String subtitle, required String time}) {
    return TacticalCard(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      borderRadius: 28,
      child: Row(
        children: [
          // UPDATED: Replaced dummy URL with person icon
          CircleAvatar(
            radius: 24.r,
            backgroundColor: TacticalColors.surfaceContainerHighest,
            child: Icon(Icons.person, color: TacticalColors.primary, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(color: TacticalColors.primary, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white54, fontSize: 13.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(color: TacticalColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(16.r)),
          child: Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(color: TacticalColors.secondaryContainer, shape: BoxShape.circle),
              ),
              SizedBox(width: 8.w),
              Text(
                "SYNC ACTIVE",
                style: TextStyle(color: Colors.white54, fontSize: 9.sp, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        const Text("|", style: TextStyle(color: Colors.white24)),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(color: TacticalColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(16.r)),
          child: Row(
            children: [
              Icon(Icons.battery_4_bar, color: Colors.white54, size: 12.sp),
              SizedBox(width: 4.w),
              Text(
                "88%",
                style: TextStyle(color: Colors.white54, fontSize: 9.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
