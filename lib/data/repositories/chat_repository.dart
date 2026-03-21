import '../api_client.dart';

class ChatRepository {
  final ApiClient _apiClient;
  ChatRepository(this._apiClient);

  // GET /chat/{incident_id}/messages
  Future<List<dynamic>> getMessages(String incidentId) async {
    return await _apiClient.getList('/chat/$incidentId/messages');
  }

  // POST /chat/{incident_id}/messages
  Future<Map<String, dynamic>> sendMessage({
    required String incidentId,
    required String senderId,
    required String content,
    bool isSystemAlert = false,
  }) async {
    return await _apiClient.post('/chat/$incidentId/messages', {
      "sender_id": senderId,
      "content": content,
      "is_system_alert": isSystemAlert,
    });
  }
}