import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/session_manager.dart';

// EVENTS
abstract class TaskDetailsEvent {}

class LoadActiveTask extends TaskDetailsEvent {}

class UpdateStatus extends TaskDetailsEvent {
  final String status;
  UpdateStatus(this.status);
}

// STATES
abstract class TaskDetailsState {}

class TaskDetailsInitial extends TaskDetailsState {}

class TaskDetailsLoading extends TaskDetailsState {}

class TaskDetailsLoaded extends TaskDetailsState {
  final Map<String, dynamic> data;
  TaskDetailsLoaded(this.data);
}

class TaskDetailsEmpty extends TaskDetailsState {}

class TaskDetailsError extends TaskDetailsState {
  final String error;
  TaskDetailsError(this.error);
}

// BLOC
class TaskDetailsBloc extends Bloc<TaskDetailsEvent, TaskDetailsState> {
  final TaskRepository repository;
  final SessionManager session = SessionManager();

  TaskDetailsBloc(this.repository) : super(TaskDetailsInitial()) {
    on<LoadActiveTask>((event, emit) async {
      emit(TaskDetailsLoading());
      try {
        final userId = await session.getUserId();
        if (userId == null) throw Exception("Session Expired");

        final data = await repository.getActiveTask(userId);
        emit(TaskDetailsLoaded(data));
      } catch (e) {
        // FIX: Look for the actual error message sent by the backend, not the HTTP code
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains("no active mission") || errorStr.contains("404")) {
          emit(TaskDetailsEmpty());
        } else {
          emit(TaskDetailsError(e.toString().replaceAll('Exception: ', '')));
        }
      }
    });

    on<UpdateStatus>((event, emit) async {
      if (state is TaskDetailsLoaded) {
        final currentData = (state as TaskDetailsLoaded).data;
        try {
          await repository.updateTaskStatus(currentData['task_id'], event.status);
          add(LoadActiveTask()); // Refresh data after status change
        } catch (e) {
          emit(TaskDetailsError(e.toString().replaceAll('Exception: ', '')));
        }
      }
    });
  }
}
