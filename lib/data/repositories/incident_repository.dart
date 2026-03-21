import '../api_client.dart';

class IncidentRepository {
  final ApiClient _apiClient;
  IncidentRepository(this._apiClient);

  Future<Map<String, dynamic>> reportIncident({
    required String id,
    required String reporterId,
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    required int requiredVolunteers,
    required String reportedAt,
  }) async {
    return await _apiClient.post('/incidents/', {
      "id": id,
      "reporter_id": reporterId,
      "category": category,
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
      "required_volunteers": requiredVolunteers,
      "reported_at": reportedAt,
    });
  }

  Future<List<dynamic>> getMyIncidents(String userId) async {
    return await _apiClient.getList('/incidents/me/$userId');
  }

  Future<List<dynamic>> getPendingIncidents() async {
    return await _apiClient.getList('/incidents/pending');
  }

  // NEW: Upload scene evidence
  Future<Map<String, dynamic>> uploadEvidence(String incidentId, String filePath) async {
    return await _apiClient.upload('/incidents/$incidentId/evidence', filePath);
  }
}
