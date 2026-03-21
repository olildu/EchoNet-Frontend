import 'package:flutter/material.dart';
import '../../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import 'package:frontend/presentation/widgets/tactical_button.dart';
import '../../../data/session_manager.dart';
import '../../../data/api_client.dart'; // NEW IMPORT

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggle States
  bool _emergencyUpdates = true;
  bool _volunteerMessages = true;
  bool _statusUpdates = true;
  bool _allowLocationAccess = true;
  bool _allowVolunteersContact = false;
  bool _shareLiveLocation = true;

  String _userName = "CITIZEN";

  // NEW: Dynamic Contacts State
  List<dynamic> _contacts = [];
  bool _isLoadingContacts = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadContacts(); // Trigger contact sync
  }

  Future<void> _loadUserName() async {
    final name = await SessionManager().getFullName();
    if (name != null && mounted) {
      setState(() => _userName = name.toUpperCase());
    }
  }

  // NEW: Fetch contacts from backend
  Future<void> _loadContacts() async {
    final userId = await SessionManager().getUserId();
    if (userId != null) {
      try {
        final contacts = await ApiClient().getList('/auth/users/$userId/contacts');
        if (mounted) {
          setState(() {
            _contacts = contacts;
            _isLoadingContacts = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoadingContacts = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildProfileHeader(),
                    const SizedBox(height: 32),

                    // NOTIFICATIONS
                    _buildSectionHeader("NOTIFICATIONS"),
                    const SizedBox(height: 16),
                    _buildToggleCard(
                      icon: Icons.ac_unit,
                      title: "Emergency Updates",
                      value: _emergencyUpdates,
                      onChanged: (val) => setState(() => _emergencyUpdates = val),
                    ),
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      icon: Icons.volunteer_activism,
                      title: "Volunteer Messages",
                      value: _volunteerMessages,
                      onChanged: (val) => setState(() => _volunteerMessages = val),
                    ),
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      icon: Icons.trending_up,
                      title: "Status Updates",
                      value: _statusUpdates,
                      onChanged: (val) => setState(() => _statusUpdates = val),
                    ),
                    const SizedBox(height: 32),

                    // LOCATION
                    _buildSectionHeader("LOCATION"),
                    const SizedBox(height: 16),
                    _buildLocationCard(),
                    const SizedBox(height: 32),

                    // PRIVACY & SAFETY
                    _buildSectionHeader("PRIVACY & SAFETY"),
                    const SizedBox(height: 16),
                    _buildToggleCard(
                      icon: Icons.shield_outlined,
                      title: "Allow volunteers to\ncontact me",
                      value: _allowVolunteersContact,
                      onChanged: (val) => setState(() => _allowVolunteersContact = val),
                    ),
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      icon: Icons.radar,
                      title: "Share live location during\nemergencies",
                      value: _shareLiveLocation,
                      onChanged: (val) => setState(() => _shareLiveLocation = val),
                    ),
                    const SizedBox(height: 32),

                    // EMERGENCY CONTACTS
                    _buildSectionHeader("EMERGENCY CONTACTS", actionText: "+ ADD CONTACT"),
                    const SizedBox(height: 16),
                    _buildContactsSection(), // UPDATED
                    const SizedBox(height: 32),

                    // SUPPORT
                    _buildSectionHeader("SUPPORT"),
                    const SizedBox(height: 16),
                    _buildSupportGroupCard(),
                    const SizedBox(height: 40),

                    // LOGOUT & DELETE
                    TacticalButton(
                      text: "LOGOUT",
                      isGradient: true,
                      textColor: Colors.black,
                      onPressed: () async {
                        await SessionManager().clearSession();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        "DELETE ACCOUNT",
                        style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- APP BAR ---
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Text(
            "SETTINGS",
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: TacticalColors.primaryContainer,
            ),
          ),
          const Spacer(),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   decoration: BoxDecoration(color: TacticalColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(20)),
          //   child: const Text(
          //     "EDIT PROFILE",
          //     style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          //   ),
          // ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: TacticalColors.surfaceContainerHigh, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: TacticalColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  // --- PROFILE HEADER ---
  Widget _buildProfileHeader() {
    return TacticalCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: TacticalColors.primaryContainer.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.account_circle, color: TacticalColors.primaryContainer, size: 32),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: TacticalColors.surfaceContainerLow, shape: BoxShape.circle),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: TacticalColors.secondaryContainer, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.black, size: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text("Sector 7-B | Verified\nResponder", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SECTION HEADER ---
  Widget _buildSectionHeader(String title, {String? actionText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: TacticalColors.primaryContainer, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.0),
        ),
        if (actionText != null)
          Text(
            actionText,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
      ],
    );
  }

  // --- INDIVIDUAL TOGGLE CARD ---
  Widget _buildToggleCard({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return TacticalCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      borderRadius: 28,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.black, // FIXED: Thumb is now black
            activeTrackColor: TacticalColors.primaryContainer, // FIXED: Track is Orange
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // --- LOCATION CARD ---
  Widget _buildLocationCard() {
    return TacticalCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 32,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: TacticalColors.primary, size: 22),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Allow location access",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Switch(
                value: _allowLocationAccess,
                activeColor: Colors.black, // FIXED: Thumb is now black
                activeTrackColor: TacticalColors.primaryContainer, // FIXED: Track is Orange
                inactiveThumbColor: Colors.white54,
                inactiveTrackColor: Colors.white10,
                onChanged: (val) => setState(() => _allowLocationAccess = val),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: TacticalColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.my_location, color: TacticalColors.primary, size: 16),
                SizedBox(width: 12),
                Text(
                  "UPDATE CURRENT LOCATION",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- DYNAMIC CONTACTS SECTION ---
  Widget _buildContactsSection() {
    if (_isLoadingContacts) {
      return const Center(child: CircularProgressIndicator(color: TacticalColors.primaryContainer));
    }

    if (_contacts.isEmpty) {
      return TacticalCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        child: const Center(
          child: Text("No emergency contacts secured yet.", style: TextStyle(color: Colors.white54, fontSize: 13)),
        ),
      );
    }

    return Column(
      children: _contacts.map((contact) {
        final name = contact['name'] ?? 'Unknown';
        final phone = contact['phone'] ?? 'No Number';
        final isPrimary = contact['is_primary'] == true;
        final initial = name.toString().isNotEmpty ? name.toString()[0].toUpperCase() : '?';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TacticalCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            borderRadius: 32,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(color: TacticalColors.surfaceContainerHighest, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(color: TacticalColors.primary, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          if (isPrimary) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: TacticalColors.errorContainer, borderRadius: BorderRadius.circular(8)),
                              child: const Text(
                                "PRIMARY",
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(phone, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.drag_handle, color: Colors.white38),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- SUPPORT GROUP CARD ---
  Widget _buildSupportGroupCard() {
    return TacticalCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: 32,
      child: Column(
        children: [
          _buildSupportItem(Icons.help_outline, "Help/FAQ"),
          _buildSupportItem(Icons.support_agent, "Contact Support"),
          _buildSupportItem(Icons.info_outline, "App Info"),
        ],
      ),
    );
  }

  Widget _buildSupportItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: TacticalColors.primary, size: 22),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
