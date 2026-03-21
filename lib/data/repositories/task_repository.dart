import '../api_client.dart';

class TaskRepository {
  final ApiClient _apiClient;
  TaskRepository(this._apiClient);

  Future<Map<String, dynamic>> acceptTask({required String incidentId, required String volunteerId}) async {
    return await _apiClient.post('/tasks/accept', {"incident_id": incidentId, "volunteer_id": volunteerId});
  }

  Future<Map<String, dynamic>> getActiveTask(String volunteerId) async {
    return await _apiClient.get('/tasks/active/$volunteerId');
  }

  // UPDATED: Changed from .post to .put
  Future<Map<String, dynamic>> updateTaskStatus(String taskId, String status) async {
    return await _apiClient.put('/tasks/$taskId/status?status=$status', {});
  }
}
