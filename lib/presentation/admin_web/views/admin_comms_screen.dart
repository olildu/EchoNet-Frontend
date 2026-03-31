import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/presentation/theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import '../../../../logic/admin/admin_bloc.dart';
import '../../../../logic/chat/chat_bloc.dart';

class AdminCommsScreen extends StatefulWidget {
  const AdminCommsScreen({super.key});

  @override
  State<AdminCommsScreen> createState() => _AdminCommsScreenState();
}

class _AdminCommsScreenState extends State<AdminCommsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _broadcastMsg = TextEditingController();
  final _chatMsg = TextEditingController();
  String _selectedIncidentId = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TACTICAL COMMUNICATIONS",
            style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          SizedBox(height: 24.h),
          TabBar(
            controller: _tabController,
            indicatorColor: TacticalColors.primaryContainer,
            tabs: const [
              Tab(text: "GLOBAL BROADCAST"),
              Tab(text: "INCIDENT OVERWATCH"),
            ],
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: TabBarView(controller: _tabController, children: [_buildBroadcastTab(), _buildOverwatchTab()]),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastTab() {
    return TacticalCard(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          TextField(
            controller: _broadcastMsg,
            maxLines: 5,
            decoration: const InputDecoration(hintText: "Enter Broadcast Message...", filled: true),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<AdminBloc>().add(SendGlobalBroadcast("Critical", _broadcastMsg.text));
                _broadcastMsg.clear();
              },
              child: const Text("INITIATE EMERGENCY BROADCAST"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverwatchTab() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, adminState) {
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: adminState.incidents.length,
                itemBuilder: (context, index) {
                  final inc = adminState.incidents[index];
                  return ListTile(
                    title: Text(inc['category'], style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      setState(() => _selectedIncidentId = inc['id']);
                      context.read<ChatBloc>().add(FetchMessages(inc['id']));
                    },
                  );
                },
              ),
            ),
            Expanded(
              flex: 7,
              child: _selectedIncidentId.isEmpty
                  ? const Center(child: Text("SELECT A CHANNEL"))
                  : Column(
                      children: [
                        Expanded(
                          child: BlocBuilder<ChatBloc, ChatState>(
                            builder: (context, chatState) {
                              if (chatState is ChatLoaded) {
                                return ListView(children: chatState.messages.map((m) => Text(m['content'])).toList());
                              }
                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                        TextField(
                          controller: _chatMsg,
                          onSubmitted: (val) {
                            context.read<ChatBloc>().add(SendMessage(_selectedIncidentId, val));
                            _chatMsg.clear();
                          },
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
