import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/data/api_client.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/chat_repository.dart';
import 'package:frontend/data/repositories/incident_repository.dart';
import 'package:frontend/data/repositories/task_repository.dart';
import 'package:frontend/data/services/websocket_service.dart';
import 'package:frontend/logic/chat/chat_bloc.dart';
import 'package:frontend/logic/incident/incident_bloc.dart';
import 'package:frontend/logic/incident/incident_history_bloc.dart';
import 'package:frontend/logic/login/login_bloc.dart';
import 'package:frontend/logic/map/location_tracking_bloc.dart';
import 'package:frontend/logic/map/map_bloc.dart';
import 'package:frontend/logic/profile/profile_bloc.dart';
import 'package:frontend/logic/task/available_tasks_bloc.dart';
import 'package:frontend/logic/task/task_bloc.dart';
import 'package:frontend/logic/task/task_details_bloc.dart';
import 'package:frontend/presentation/admin_web/admin_main_screen.dart';
import 'package:frontend/presentation/admin_web/views/admin_comms_screen.dart';
import 'package:frontend/presentation/admin_web/views/admin_incidents_screen.dart';
import 'package:frontend/presentation/auth/guardian_nomination_screen.dart';
import 'package:frontend/presentation/auth/volunteer_registration_step1.dart';
import 'package:frontend/presentation/auth/volunteer_registration_step2.dart';
import 'package:frontend/presentation/citizen/citizen_main_screen.dart';
import 'package:frontend/presentation/citizen/dashboard/maps_screen.dart';
import 'package:frontend/presentation/citizen/dashboard/report_emergency_screen.dart';
import 'package:frontend/presentation/citizen/dashboard/reports_screen.dart';
import 'package:frontend/presentation/citizen/dashboard/system_screen.dart';
import 'package:frontend/presentation/volunteer/dashboard/messages_screen.dart';
import 'package:frontend/presentation/volunteer/dashboard/task_details_screen.dart';
import 'package:frontend/presentation/volunteer/dashboard/volunteer_maps_screen.dart';
import 'package:frontend/presentation/volunteer/dashboard/volunteer_profile_screen.dart';
import 'package:frontend/presentation/volunteer/volunteer_main_screen.dart';
import 'package:frontend/data/session_manager.dart';
import 'package:frontend/presentation/widgets/responsive_layout.dart';
import 'presentation/theme/tactical_theme.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/citizen_registration.dart';
import 'logic/registration/registration_bloc.dart';
import 'data/repositories/citizen_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = SessionManager();
  final role = await session.getRole();

  String initialRoute = '/';
  if (role == 'CITIZEN') {
    initialRoute = '/citizen_dashboard';
  } else if (role == 'AUTHORITY' || role == 'NGO') {
    // FIX: Route admins to the web dashboard at startup
    initialRoute = '/admin_dashboard';
  } else if (role == 'VOLUNTEER') {
    initialRoute = '/volunteer_dashboard';
  }

  runApp(EchoNetApp(startRoute: initialRoute));
}

class EchoNetApp extends StatelessWidget {
  final String startRoute;
  const EchoNetApp({super.key, required this.startRoute});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => CitizenRepository()),
        RepositoryProvider(create: (context) => AuthRepository(ApiClient())),
        RepositoryProvider(create: (context) => IncidentRepository(ApiClient())),
        RepositoryProvider(create: (context) => TaskRepository(ApiClient())),
        RepositoryProvider(create: (context) => ChatRepository(ApiClient())),
        RepositoryProvider(create: (context) => WebSocketService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => RegistrationBloc(context.read<CitizenRepository>())),
          BlocProvider(create: (context) => LoginBloc(authRepository: context.read<AuthRepository>())),
          BlocProvider(create: (context) => ProfileBloc(context.read<AuthRepository>())),
          BlocProvider(create: (context) => IncidentBloc(context.read<IncidentRepository>())),
          BlocProvider(create: (context) => TaskBloc(context.read<TaskRepository>())),
          BlocProvider(create: (context) => IncidentHistoryBloc(context.read<IncidentRepository>())),
          BlocProvider(create: (context) => ChatBloc(context.read<ChatRepository>(), context.read<WebSocketService>())),
          BlocProvider(create: (context) => AvailableTasksBloc(context.read<IncidentRepository>(), context.read<WebSocketService>())),
          BlocProvider(create: (context) => TaskDetailsBloc(context.read<TaskRepository>())),
          BlocProvider(create: (context) => MapBloc(context.read<IncidentRepository>())),
          BlocProvider(create: (context) => LocationTrackingBloc(context.read<WebSocketService>())),
        ],
        child: ScreenUtilInit(
          designSize: MediaQuery.of(context).size.width > 1000 ? const Size(1888, 938) : const Size(411.42857142857144, 899.4285714285714),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              title: 'EchoNet',
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.dark,
              darkTheme: TacticalTheme.darkTheme,
              initialRoute: startRoute,
              routes: {
                '/': (context) => const LoginScreen(),
                '/register_citizen': (context) => const CitizenRegistrationScreen(),
                '/nominate_guardians': (context) => const GuardianNominationScreen(),
                '/register_volunteer': (context) => const VolunteerRegistrationStep1(),
                '/register_volunteer_step2': (context) => const VolunteerRegistrationStep2(),
                '/citizen_dashboard': (context) => const CitizenMainScreen(),
                '/volunteer_dashboard': (context) => const VolunteerMainScreen(),
                '/reports': (context) => const ReportsScreen(),
                '/report_emergency': (context) => const ReportEmergencyScreen(),
                '/maps': (context) => const MapsScreen(),
                '/settings': (context) => const SettingsScreen(),
                '/volunteer_task_details': (context) => const TaskDetailsScreen(),
                '/volunteer_messages': (context) => const MessagesScreen(),
                '/volunteer_maps': (context) => const VolunteerMapsScreen(),
                '/volunteer_profile': (context) => const VolunteerProfileScreen(),
                '/admin_dashboard': (context) => const AdminMainScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}
