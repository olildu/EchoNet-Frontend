import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/session_manager.dart'; // Added
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  final SessionManager sessionManager = SessionManager(); // Added

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<SubmitLogin>(_onSubmitLogin);
  }

  Future<void> _onSubmitLogin(SubmitLogin event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final response = await authRepository.login(event.phone, event.password);

      // PERSISTENCE: Save credentials locally
      await sessionManager.saveSession(
        response['access_token'],
        response['user_id'].toString(),
        response['user_role'],
        response['full_name'], // NEW
      );

      emit(LoginSuccess(response['user_role']));
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(LoginFailure(errorMessage));
    }
  }
}
