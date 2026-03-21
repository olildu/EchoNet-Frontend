import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // NEW
import 'dart:math';
import '../../data/repositories/incident_repository.dart';
import '../../data/session_manager.dart';

// --- EVENTS ---
abstract class IncidentEvent {}

// NEW: Event to handle photo capture
class PickIncidentImage extends IncidentEvent {
  final ImageSource source;
  PickIncidentImage(this.source);
}

class SubmitIncident extends IncidentEvent {
  final String category;
  final String description;
  final String priority;
  final int peopleAffected;
  final String? imagePath; // NEW: Pass the path

  SubmitIncident({
    required this.category,
    required this.description,
    required this.priority,
    required this.peopleAffected,
    this.imagePath,
  });
}

// --- STATES ---
abstract class IncidentState {}
class IncidentInitial extends IncidentState {}
class IncidentLoading extends IncidentState {}
class IncidentSuccess extends IncidentState {}
// NEW: Image captured state for the UI preview
class IncidentImagePicked extends IncidentState {
  final String path;
  IncidentImagePicked(this.path);
}
class IncidentFailure extends IncidentState {
  final String error;
  IncidentFailure(this.error);
}

// --- BLOC ---
class IncidentBloc extends Bloc<IncidentEvent, IncidentState> {
  final IncidentRepository repository;
  final SessionManager sessionManager = SessionManager();
  final ImagePicker _picker = ImagePicker(); // NEW

  IncidentBloc(this.repository) : super(IncidentInitial()) {
    
    // NEW: Logic to capture photo
    on<PickIncidentImage>((event, emit) async {
      try {
        final XFile? photo = await _picker.pickImage(source: event.source, imageQuality: 50);
        if (photo != null) emit(IncidentImagePicked(photo.path));
      } catch (e) {
        emit(IncidentFailure("Camera access denied."));
      }
    });

    on<SubmitIncident>((event, emit) async {
      emit(IncidentLoading());
      try {
        final reporterId = await sessionManager.getUserId();
        if (reporterId == null) throw Exception("Session expired. Please log in again.");

        final String incidentId = _generateUuidV4();

        int requiredVolunteers = 1;
        if (event.priority == "MODERATE") requiredVolunteers = 2;
        if (event.priority == "CRITICAL") requiredVolunteers = 3;
        if (event.peopleAffected > requiredVolunteers) requiredVolunteers = event.peopleAffected;

        double simLat = 26.9124 + (Random().nextDouble() * 0.01);
        double simLng = 75.7873 + (Random().nextDouble() * 0.01);

        // 1. Submit the text report first
        await repository.reportIncident(
          id: incidentId,
          reporterId: reporterId,
          category: _mapCategory(event.category),
          description: event.description.isEmpty ? "Emergency reported via EchoNet." : event.description,
          latitude: simLat,
          longitude: simLng,
          requiredVolunteers: requiredVolunteers,
          reportedAt: DateTime.now().toUtc().toIso8601String(),
        );

        // 2. If an image was picked, upload it linked to the new Incident ID
        if (event.imagePath != null) {
          await repository.uploadEvidence(incidentId, event.imagePath!);
        }

        emit(IncidentSuccess());
      } catch (e) {
        emit(IncidentFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }

  String _mapCategory(String uiCategory) {
    final map = {
      "MEDICAL": "MEDICAL", "FIRE": "FIRE", "RESCUE": "RESCUE",
      "FLOOD": "FLOOD", "FOOD/SUPPLIES": "FOOD_SUPPLY", "SHELTER": "SHELTER",
      "MENTAL SUPPORT": "MENTAL_HEALTH", "INFRASTRUCTURE": "INFRASTRUCTURE",
    };
    return map[uiCategory] ?? "GENERAL";
  }

  String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; 
    bytes[8] = (bytes[8] & 0x3f) | 0x80; 
    final chars = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
    return '${chars.sublist(0, 4).join()}-${chars.sublist(4, 6).join()}-${chars.sublist(6, 8).join()}-${chars.sublist(8, 10).join()}-${chars.sublist(10, 16).join()}';
  }
}