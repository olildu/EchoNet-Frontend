import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/incident_repository.dart';
import '../../data/services/websocket_service.dart'; // NEW IMPORT

abstract class AvailableTasksEvent {}
class FetchAvailableTasks extends AvailableTasksEvent {}
class DeclineTask extends AvailableTasksEvent {
  final String incidentId;
  DeclineTask(this.incidentId);
}

abstract class AvailableTasksState {}
class AvailableTasksInitial extends AvailableTasksState {}
class AvailableTasksLoading extends AvailableTasksState {}
class AvailableTasksLoaded extends AvailableTasksState {
  final List<dynamic> incidents;
  AvailableTasksLoaded(this.incidents);
}
class AvailableTasksFailure extends AvailableTasksState {
  final String error;
  AvailableTasksFailure(this.error);
}

class AvailableTasksBloc extends Bloc<AvailableTasksEvent, AvailableTasksState> {
  final IncidentRepository repository;
  final WebSocketService wsService; // NEW: Added WS Service

  final Set<String> _declinedTaskIds = {};

  AvailableTasksBloc(this.repository, this.wsService) : super(AvailableTasksInitial()) {
    
    // WOW FACTOR: Listen to real-time incident alerts from backend
    wsService.connect();
    wsService.stream.listen((data) {
      if (data.toString().contains('"type": "NEW_INCIDENT"')) {
        add(FetchAvailableTasks()); // Instantly refresh UI without the user swiping down
      }
    });

    on<FetchAvailableTasks>((event, emit) async {
      emit(AvailableTasksLoading());
      try {
        final incidents = await repository.getPendingIncidents();
        final filteredIncidents = incidents.where((incident) => !_declinedTaskIds.contains(incident['id'])).toList();
        emit(AvailableTasksLoaded(filteredIncidents));
      } catch (e) {
        emit(AvailableTasksFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<DeclineTask>((event, emit) {
      _declinedTaskIds.add(event.incidentId);
      if (state is AvailableTasksLoaded) {
        final currentIncidents = (state as AvailableTasksLoaded).incidents;
        final filteredIncidents = currentIncidents.where((incident) => incident['id'] != event.incidentId).toList();
        emit(AvailableTasksLoaded(filteredIncidents));
      }
    });
  }
}