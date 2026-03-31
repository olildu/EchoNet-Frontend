import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/citizen_repository.dart';
import '../../data/session_manager.dart';

// --- EVENTS ---
abstract class RegistrationEvent {}

class SubmitCitizenRegistration extends RegistrationEvent {
  final String name;
  final String phone;
  final String? nationalId;
  SubmitCitizenRegistration(this.name, this.phone, this.nationalId);
}

class SubmitEmergencyContacts extends RegistrationEvent {
  final String userId;
  final List<Map<String, dynamic>> contacts;
  SubmitEmergencyContacts(this.userId, this.contacts);
}

class SubmitVolunteerRegistration extends RegistrationEvent {
  final Map<String, dynamic> data;
  SubmitVolunteerRegistration(this.data);
}

// --- STATES ---
abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {
  final String userId;
  final String role; // <-- PASS THE ROLE
  RegistrationSuccess(this.userId, {this.role = "CITIZEN"});
}

class RegistrationFailure extends RegistrationState {
  final String error;
  RegistrationFailure(this.error);
}

// --- BLOC ---
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final CitizenRepository repository;
  final SessionManager sessionManager = SessionManager();

  RegistrationBloc(this.repository) : super(RegistrationInitial()) {
    on<SubmitCitizenRegistration>((event, emit) async {
      emit(RegistrationLoading());
      try {
        final response = await repository.registerCitizen(fullName: event.name, phone: event.phone, nationalId: event.nationalId);
        await sessionManager.saveSession(response['access_token'], response['user_id'].toString(), response['user_role'], response['full_name']);
        emit(RegistrationSuccess(response['user_id'].toString(), role: response['user_role']));
      } catch (e) {
        emit(RegistrationFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<SubmitEmergencyContacts>((event, emit) async {
      emit(RegistrationLoading());
      try {
        await repository.saveEmergencyContacts(userId: event.userId, contacts: event.contacts);
        emit(RegistrationSuccess(event.userId, role: 'CITIZEN'));
      } catch (e) {
        emit(RegistrationFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<SubmitVolunteerRegistration>((event, emit) async {
      emit(RegistrationLoading());
      try {
        final response = await repository.registerVolunteer(
          name: event.data['name'],
          phone: event.data['phone'],
          email: event.data['email'],
          age: int.parse(event.data['age']),
          role: _mapOrgToRole(event.data['org']),
          skills: _mapSkillsToEnums(event.data['skills']),
        );

        await sessionManager.saveSession(response['access_token'], response['user_id'].toString(), response['user_role'], response['full_name']);

        // Emit success with the actual role from the backend (AUTHORITY, NGO, or VOLUNTEER)
        emit(RegistrationSuccess("volunteer_complete", role: response['user_role']));
      } catch (e) {
        emit(RegistrationFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }

  String _mapOrgToRole(String org) {
    if (org == "NGO") return "NGO";
    if (org == "ADMINISTRATION") return "AUTHORITY";
    return "VOLUNTEER";
  }

  List<String> _mapSkillsToEnums(List<String> skills) {
    final map = {
      "FIRST AID": "MEDICAL",
      "MEDICAL\nASSISTANCE": "MEDICAL",
      "FIRE SAFETY": "FIRE",
      "FIREFIGHTING\nBASICS": "FIRE",
      "RESCUE\nOPERATIONS": "RESCUE",
      "SWIMMING /\nLIFEGUARD": "RESCUE",
      "BOAT\nHANDLING": "RESCUE",
      "LOGISTICS /\nDISTRIBUTION": "FOOD_SUPPLY",
      "SHELTER\nMANAGEMENT": "SHELTER",
      "COUNSELING /\nMENTAL SUPPORT": "MENTAL_HEALTH",
      "SEARCH &\nMISSING PERSON": "MISSING_PERSON",
      "DEBRIS\nREMOVAL": "INFRASTRUCTURE",
    };
    return skills.map((s) => map[s] ?? "GENERAL").toSet().toList();
  }
}
