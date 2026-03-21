abstract class LoginEvent {}

class SubmitLogin extends LoginEvent {
  final String phone;
  final String password;

  SubmitLogin({required this.phone, required this.password});
}