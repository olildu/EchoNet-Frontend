import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/api_client.dart';

// --- EVENTS ---
abstract class AdminEvent {}
class LoadIncidents extends AdminEvent {}
class SelectIncident extends AdminEvent {
  final Map<String, dynamic> incident;
  SelectIncident(this.incident);
}
class DispatchVolunteer extends AdminEvent {
  final String incidentId;
  final String volunteerId;
  DispatchVolunteer(this.incidentId, this.volunteerId);
}

// --- STATE ---
class AdminState {
  final bool isLoading;
  final List<dynamic> incidents;
  final Map<String, dynamic>? selectedIncident;
  final List<dynamic> responders;
  final String? error;

  AdminState({this.isLoading = false, this.incidents = const [], this.selectedIncident, this.responders = const [], this.error});

  AdminState copyWith({bool? isLoading, List<dynamic>? incidents, Map<String, dynamic>? selectedIncident, List<dynamic>? responders, String? error}) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      incidents: incidents ?? this.incidents,
      selectedIncident: selectedIncident ?? this.selectedIncident,
      responders: responders ?? this.responders,
      error: error ?? this.error,
    );
  }
}

// --- BLOC ---
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final ApiClient apiClient = ApiClient();

  AdminBloc() : super(AdminState()) {
    on<LoadIncidents>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final incidents = await apiClient.getReq('/incidents/all');
        emit(state.copyWith(isLoading: false, incidents: incidents as List<dynamic>));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    on<SelectIncident>((event, emit) async {
      emit(state.copyWith(selectedIncident: event.incident, responders: [], isLoading: true));
      try {
        // Fetch nearest volunteers via your matching engine
        final response = await apiClient.getReq('/matching/nearest-volunteers/${event.incident['id']}');
        emit(state.copyWith(isLoading: false, responders: response['nearest_volunteers'] ?? []));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });

    on<DispatchVolunteer>((event, emit) async {
      try {
        await apiClient.post('/tasks/accept', {
          "incident_id": event.incidentId,
          "volunteer_id": event.volunteerId
        });
        // Reload incidents after successful dispatch
        add(LoadIncidents());
      } catch (e) {
        emit(state.copyWith(error: "Dispatch Failed: ${e.toString()}"));
      }
    });
  }
}