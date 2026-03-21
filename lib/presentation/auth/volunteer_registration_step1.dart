import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_text_field.dart';
import 'package:frontend/presentation/widgets/tactical_app_bar.dart';
import 'package:frontend/presentation/widgets/tactical_button.dart';

class VolunteerRegistrationStep1 extends StatefulWidget {
  const VolunteerRegistrationStep1({super.key});

  @override
  State<VolunteerRegistrationStep1> createState() => _VolunteerRegistrationStep1State();
}

class _VolunteerRegistrationStep1State extends State<VolunteerRegistrationStep1> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedOrg = 'ADMINISTRATION';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: const TacticalAppBar(title: "MISSION REGISTRATION"),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressIndicator(),
                  const SizedBox(height: 32),
                  const Text(
                    "Volunteer\nRegistration",
                    style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Tell us about yourself to begin your\nmission enrollment.",
                    style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
                  ),
                  const SizedBox(height: 40),

                  TacticalTextField(label: "FULL NAME", icon: Icons.person, hint: "Commander Shepard", controller: _nameController),
                  const SizedBox(height: 20),
                  // UPDATED: isNumeric added
                  TacticalTextField(label: "AGE", icon: Icons.calendar_today, hint: "28", controller: _ageController, isNumeric: true),
                  const SizedBox(height: 20),
                  // UPDATED: isNumeric added, spaces removed from hint
                  TacticalTextField(label: "PHONE NUMBER", icon: Icons.phone, hint: "15550001117", controller: _phoneController, isNumeric: true),
                  const SizedBox(height: 40),

                  const Text(
                    "ORGANIZATION TYPE",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 16),
                  _buildOrgButton("NGO", Icons.domain),
                  const SizedBox(height: 12),
                  _buildOrgButton("ADMINISTRATION", Icons.account_balance),
                  const SizedBox(height: 12),
                  _buildOrgButton("INDEPENDENT", Icons.person_pin),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "STEP 1 OF 2",
              style: TextStyle(color: TacticalColors.primaryContainer, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            Text(
              "IDENTIFICATION",
              style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: 4,
                decoration: BoxDecoration(color: TacticalColors.primaryContainer, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                height: 4,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrgButton(String title, IconData icon) {
    bool isSelected = _selectedOrg == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedOrg = title),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? null : TacticalColors.surfaceContainerLow,
          gradient: isSelected ? TacticalColors.sosGradient : null,
          borderRadius: BorderRadius.circular(32),
          boxShadow: isSelected ? [BoxShadow(color: TacticalColors.primaryContainer.withOpacity(0.3), blurRadius: 20)] : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.black : TacticalColors.primaryContainer, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: TacticalColors.background,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.chevron_left, color: Colors.white54, size: 20),
                SizedBox(width: 4),
                Text(
                  "BACK",
                  style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: TacticalButton(
              text: "NEXT",
              onPressed: () => Navigator.pushNamed(
                context,
                '/register_volunteer_step2',
                arguments: {
                  // UPDATED: Added .trim() to ensure no accidental spaces are submitted
                  "name": _nameController.text.trim(),
                  "age": _ageController.text.trim(),
                  "email": _emailController.text.trim(),
                  "phone": _phoneController.text.trim(),
                  "org": _selectedOrg,
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
