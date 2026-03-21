import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/incident_repository.dart';
import '../../data/session_manager.dart';

// --- EVENTS ---
abstract class IncidentHistoryEvent {}

class FetchMyIncidents extends IncidentHistoryEvent {}

// --- STATES ---
abstract class IncidentHistoryState {}

class IncidentHistoryInitial extends IncidentHistoryState {}

class IncidentHistoryLoading extends IncidentHistoryState {}

class IncidentHistoryLoaded extends IncidentHistoryState {
  final List<dynamic> incidents;
  IncidentHistoryLoaded(this.incidents);
}

class IncidentHistoryFailure extends IncidentHistoryState {
  final String error;
  IncidentHistoryFailure(this.error);
}

// --- BLOC ---
class IncidentHistoryBloc extends Bloc<IncidentHistoryEvent, IncidentHistoryState> {
  final IncidentRepository repository;

  IncidentHistoryBloc(this.repository) : super(IncidentHistoryInitial()) {
    on<FetchMyIncidents>((event, emit) async {
      emit(IncidentHistoryLoading());
      try {
        // Fetch real ID from persistent session
        final userId = await SessionManager().getUserId();
        if (userId == null) throw Exception("User not authenticated.");

        final incidents = await repository.getMyIncidents(userId);
        emit(IncidentHistoryLoaded(incidents));
      } catch (e) {
        emit(IncidentHistoryFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
