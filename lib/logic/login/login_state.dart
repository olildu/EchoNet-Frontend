abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String role; // e.g., "CITIZEN" or "VOLUNTEER"
  LoginSuccess(this.role);
}

class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
}
