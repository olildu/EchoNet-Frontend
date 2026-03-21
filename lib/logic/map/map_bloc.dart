import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/incident_repository.dart';

// --- EVENTS ---
abstract class MapEvent {}
class FetchMapIntel extends MapEvent {}

// --- STATES ---
abstract class MapState {}
class MapInitial extends MapState {}
class MapLoading extends MapState {}
class MapIntelLoaded extends MapState {
  final List<dynamic> incidents;
  MapIntelLoaded(this.incidents);
}
class MapIntelError extends MapState {
  final String error;
  MapIntelError(this.error);
}

// --- BLOC ---
class MapBloc extends Bloc<MapEvent, MapState> {
  final IncidentRepository repository;

  // REFERENCE POINT (Center of your simulated grid)
  static const double centerLat = 26.9124;
  static const double centerLng = 75.7873;
  // SCALE: pixels per degree (Adjust these to fit your UI grid zoom level)
  static const double zoomScale = 15000.0; 

  MapBloc(this.repository) : super(MapInitial()) {
    on<FetchMapIntel>((event, emit) async {
      emit(MapLoading());
      try {
        final incidents = await repository.getPendingIncidents();
        emit(MapIntelLoaded(incidents));
      } catch (e) {
        emit(MapIntelError(e.toString()));
      }
    });
  }

  // --- PROJECTION LOGIC ---
  // Converts GPS coordinates to Pixel Offsets relative to the center of the UI
  static Map<String, double> projectToPixels(double lat, double lng, double screenWidth, double screenHeight) {
    // Calculate delta from center
    double dy = (lat - centerLat) * zoomScale;
    double dx = (lng - centerLng) * zoomScale;

    // Return offsets. Note: screenHeight/2 is the center of the UI.
    return {
      'top': (screenHeight / 2) - dy,
      'left': (screenWidth / 2) + dx,
    };
  }
}