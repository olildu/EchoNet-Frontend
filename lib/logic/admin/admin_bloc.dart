import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/api_client.dart';
import '../../data/services/websocket_service.dart'; // NEW IMPORT

// --- EVENTS ---
abstract class AdminEvent {}

/// Initial load of all incidents for the triage queue
class LoadIncidents extends AdminEvent {}

/// Fetch detailed records for the personnel fleet table
class LoadPersonnel extends AdminEvent {}

/// Select a specific incident to view details and find matching responders
class SelectIncident extends AdminEvent {
  final Map<String, dynamic> incident;
  SelectIncident(this.incident);
}

/// Assign a specific volunteer to an incident
class DispatchVolunteer extends AdminEvent {
  final String incidentId;
  final String volunteerId;
  DispatchVolunteer(this.incidentId, this.volunteerId);
}

/// Transmit a system-wide emergency alert
class SendGlobalBroadcast extends AdminEvent {
  final String threatLevel;
  final String message;
  SendGlobalBroadcast(this.threatLevel, this.message);
}

// --- STATE ---
class AdminState {
  final bool isLoading;
  final List<dynamic> incidents;
  final List<dynamic> personnel;
  final Map<String, dynamic>? selectedIncident;
  final List<dynamic> responders;
  final String? error;

  AdminState({
    this.isLoading = false,
    this.incidents = const [],
    this.personnel = const [],
    this.selectedIncident,
    this.responders = const [],
    this.error,
  });

  AdminState copyWith({
    bool? isLoading,
    List<dynamic>? incidents,
    List<dynamic>? personnel,
    Map<String, dynamic>? selectedIncident,
    List<dynamic>? responders,
    String? error,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      incidents: incidents ?? this.incidents,
      personnel: personnel ?? this.personnel,
      selectedIncident: selectedIncident ?? this.selectedIncident,
      responders: responders ?? this.responders,
      error: error ?? this.error,
    );
  }
}

// --- BLOC ---
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final ApiClient apiClient = ApiClient();
  final WebSocketService wsService; // NEW: WebSocket Service

  AdminBloc(this.wsService) : super(AdminState()) {
    // WOW FACTOR: Listen to real-time incident alerts from backend
    wsService.connect();
    wsService.stream.listen((data) {
      if (data.toString().contains('"type": "NEW_INCIDENT"')) {
        add(LoadIncidents()); // Instantly refresh triage queue
      }
    });

    // 1. Load Incidents for Triage
    on<LoadIncidents>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final incidents = await apiClient.getReq('/incidents/all');
        emit(state.copyWith(isLoading: false, incidents: incidents as List<dynamic>));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    // 2. Load Personnel Fleet Data
    on<LoadPersonnel>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final personnel = await apiClient.getReq('/auth/volunteers/detailed');
        emit(state.copyWith(isLoading: false, personnel: personnel as List<dynamic>));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    // 3. Select Incident and Fetch Nearest Responders
    on<SelectIncident>((event, emit) async {
      emit(state.copyWith(selectedIncident: event.incident, responders: [], isLoading: true));
      try {
        // Fetch nearest volunteers via the PostGIS matching engine
        final response = await apiClient.getReq('/matching/nearest-volunteers/${event.incident['id']}');
        emit(state.copyWith(isLoading: false, responders: response['nearest_volunteers'] ?? []));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    // 4. Dispatch Volunteer (Accept Task)
    on<DispatchVolunteer>((event, emit) async {
      try {
        await apiClient.post('/tasks/accept', {"incident_id": event.incidentId, "volunteer_id": event.volunteerId});
        // Trigger a refresh of the incident list to reflect status changes
        add(LoadIncidents());
      } catch (e) {
        emit(state.copyWith(error: "Dispatch Failed: ${e.toString()}"));
      }
    });

    // 5. Send Tactical Global Broadcast
    on<SendGlobalBroadcast>((event, emit) async {
      try {
        await apiClient.post('/chat/broadcast', {
          "sender_id": "00000000-0000-0000-0000-000000000000", // System UUID
          "content": "[${event.threatLevel.toUpperCase()}] ${event.message}",
          "is_system_alert": true,
        });
      } catch (e) {
        emit(state.copyWith(error: "Broadcast Failed: ${e.toString()}"));
      }
    });
  }
}
