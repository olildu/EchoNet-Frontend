import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/websocket_service.dart';

// --- EVENTS ---
abstract class LocationTrackingEvent {}

class StartTracking extends LocationTrackingEvent {}

class BroadcastLocation extends LocationTrackingEvent {
  final String userId;
  final double lat;
  final double lng;
  BroadcastLocation(this.userId, this.lat, this.lng);
}

// --- STATES ---
abstract class LocationTrackingState {}

class LocationTrackingInitial extends LocationTrackingState {}

class PersonnelLocationsUpdated extends LocationTrackingState {
  final Map<String, dynamic> personnel;
  PersonnelLocationsUpdated(this.personnel);
}

// --- BLOC ---
class LocationTrackingBloc extends Bloc<LocationTrackingEvent, LocationTrackingState> {
  final WebSocketService wsService;
  final Map<String, dynamic> _personnelMap = {};

  LocationTrackingBloc(this.wsService) : super(LocationTrackingInitial()) {
    on<StartTracking>((event, emit) async {
      wsService.connect();
      // Listen for broadcasts from the backend
      await emit.forEach(
        wsService.stream,
        onData: (data) {
          final String raw = data.toString();
          // Backend sends: "Live Update: {"id": "...", "lat": ..., "lng": ...}"
          if (raw.startsWith("Live Update: ")) {
            try {
              final jsonStr = raw.replaceFirst("Live Update: ", "");
              final payload = jsonDecode(jsonStr);
              _personnelMap[payload['id']] = payload;
              return PersonnelLocationsUpdated(Map.from(_personnelMap));
            } catch (e) {
              return state;
            }
          }
          return state;
        },
      );
    });

    on<BroadcastLocation>((event, emit) {
      final payload = jsonEncode({"id": event.userId, "lat": event.lat, "lng": event.lng, "timestamp": DateTime.now().toIso8601String()});
      wsService.sendMessage(payload);
    });
  }
}
