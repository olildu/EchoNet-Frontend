import '../api_client.dart';

class CitizenRepository {
  final ApiClient client = ApiClient();

  // Citizen Registration
  Future<Map<String, dynamic>> registerCitizen({required String fullName, required String phone, required String? nationalId}) async {
    return await client.post('/auth/register', {
      "full_name": fullName,
      "phone": phone,
      "password": "default_password", // Placeholder
      "role": "CITIZEN",
      "national_id": nationalId,
    });
  }

  // NEW: Volunteer Registration integration
  Future<Map<String, dynamic>> registerVolunteer({
    required String name,
    required String phone,
    required String email,
    required int age,
    required String role, // Mapping NGO/ADMIN to Backend Roles
    required List<String> skills,
  }) async {
    return await client.post('/auth/register', {
      "full_name": name,
      "phone": phone,
      "password": "default_password",
      "role": role, // NGO, AUTHORITY, or VOLUNTEER
      "age": age,
      "skills": skills, // Mapped to EmergencyCategory
    });
  }

  // Save Contacts (used by GuardianNominationScreen)
  Future<void> saveEmergencyContacts({required String userId, required List<Map<String, dynamic>> contacts}) async {
    for (var contact in contacts) {
      await client.post('/auth/users/$userId/contacts', {
        "name": contact['name'],
        "phone": contact['phone'],
        "is_primary": contact['is_primary'] ?? false,
      });
    }
  }
}
