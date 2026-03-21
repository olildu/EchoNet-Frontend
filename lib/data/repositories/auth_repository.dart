import '../api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;
  AuthRepository(this._apiClient);

  // Existing login logic
  Future<Map<String, dynamic>> login(String phone, String password) async {
    return await _apiClient.post('/auth/login', {
      'phone': phone,
      'password': password,
    });
  }

  // NEW: Fetch real metrics from the backend
  Future<Map<String, dynamic>> getVolunteerStats(String userId) async {
    return await _apiClient.get('/auth/users/$userId/stats');
  }
}