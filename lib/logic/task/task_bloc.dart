import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/session_manager.dart';

// --- EVENTS ---
abstract class TaskEvent {}
class AcceptMission extends TaskEvent {
  final String incidentId;
  AcceptMission(this.incidentId);
}

// --- STATES ---
abstract class TaskState {}
class TaskInitial extends TaskState {}
class TaskLoading extends TaskState {}
class TaskAcceptedSuccess extends TaskState {
  final String message;
  TaskAcceptedSuccess(this.message);
}
class TaskFailure extends TaskState {
  final String error;
  TaskFailure(this.error);
}

// --- BLOC ---
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  final SessionManager sessionManager = SessionManager();

  TaskBloc(this.repository) : super(TaskInitial()) {
    on<AcceptMission>((event, emit) async {
      emit(TaskLoading());
      try {
        final userId = await sessionManager.getUserId();
        if (userId == null) throw Exception("Session expired.");

        final response = await repository.acceptTask(
          incidentId: event.incidentId,
          volunteerId: userId,
        );

        emit(TaskAcceptedSuccess(response['message']));
      } catch (e) {
        emit(TaskFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}