import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';

// EVENTS
abstract class ProfileEvent {}

class FetchProfileStats extends ProfileEvent {
  final String userId;
  FetchProfileStats(this.userId);
}

// STATES
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> stats;
  ProfileLoaded(this.stats);
}

class ProfileError extends ProfileState {
  final String error;
  ProfileError(this.error);
}

// BLOC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository repository;

  ProfileBloc(this.repository) : super(ProfileInitial()) {
    on<FetchProfileStats>((event, emit) async {
      emit(ProfileLoading());
      try {
        final stats = await repository.getVolunteerStats(event.userId);
        emit(ProfileLoaded(stats));
      } catch (e) {
        emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
