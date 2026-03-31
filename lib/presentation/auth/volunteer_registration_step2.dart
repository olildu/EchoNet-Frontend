import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/logic/registration/registration_bloc.dart';
import '../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_app_bar.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import 'package:frontend/presentation/widgets/tactical_button.dart';

class VolunteerRegistrationStep2 extends StatefulWidget {
  const VolunteerRegistrationStep2({super.key});

  @override
  State<VolunteerRegistrationStep2> createState() => _VolunteerRegistrationStep2State();
}

class _VolunteerRegistrationStep2State extends State<VolunteerRegistrationStep2> {
  final List<String> _selectedSkills = ['FIRST AID', 'CPR'];

  final List<Map<String, dynamic>> _skills = [
    {"icon": Icons.medical_information, "label": "FIRST AID"},
    {"icon": Icons.favorite, "label": "CPR"},
    {"icon": Icons.medical_services, "label": "MEDICAL\nASSISTANCE"},
    {"icon": Icons.fire_extinguisher, "label": "FIRE SAFETY"},
    {"icon": Icons.local_fire_department, "label": "FIREFIGHTING\nBASICS"},
    {"icon": Icons.health_and_safety, "label": "RESCUE\nOPERATIONS"},
    {"icon": Icons.density_small, "label": "ROPE RESCUE"},
    {"icon": Icons.waves, "label": "SWIMMING /\nLIFEGUARD"},
    {"icon": Icons.directions_boat, "label": "BOAT\nHANDLING"},
    {"icon": Icons.inventory_2, "label": "LOGISTICS /\nDISTRIBUTION"},
    {"icon": Icons.house_siding, "label": "SHELTER\nMANAGEMENT"},
    {"icon": Icons.psychology, "label": "COUNSELING /\nMENTAL SUPPORT"},
    {"icon": Icons.person_search, "label": "SEARCH &\nMISSING PERSON"},
    {"icon": Icons.handyman, "label": "DEBRIS\nREMOVAL"},
    {"icon": Icons.volunteer_activism, "label": "GENERAL\nVOLUNTEER"},
  ];

  @override
  Widget build(BuildContext context) {
    final step1Data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return BlocListener<RegistrationBloc, RegistrationState>(
      listener: (context, state) {
        if (state is RegistrationSuccess && state.userId == "volunteer_complete") {
          // FIX: Check for authority roles to route to the correct dashboard
          if (state.role == 'AUTHORITY' || state.role == 'NGO') {
            Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/volunteer_dashboard', (route) => false);
          }
        } else if (state is RegistrationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: TacticalColors.errorContainer));
        }
      },
      child: Scaffold(
        backgroundColor: TacticalColors.background,
        appBar: TacticalAppBar(
          title: "MISSION REGISTRATION",
          actions: [
            Center(
              child: const Text(
                "STEP 2 OF 3",
                style: TextStyle(color: TacticalColors.primaryContainer, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
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
                      "Select Your Skills",
                      style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text("You can choose more than one", style: TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 32),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _skills.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final skill = _skills[index];
                        return _buildSkillCard(skill['label'], skill['icon']);
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildStatusOverlay(),
            _buildBottomBar(context, step1Data),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 4,
            decoration: BoxDecoration(color: TacticalColors.primaryContainer, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 4,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillCard(String label, IconData icon) {
    bool isSelected = _selectedSkills.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSkills.remove(label);
          } else {
            _selectedSkills.add(label);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? TacticalColors.primaryContainer : Colors.transparent, width: 2),
        ),
        child: TacticalCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 22,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: isSelected ? TacticalColors.primaryContainer : TacticalColors.onSurfaceVariant, size: 32),
                  const Spacer(),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5, height: 1.3),
                  ),
                ],
              ),
              if (isSelected) const Positioned(top: 0, right: 0, child: Icon(Icons.check_circle, color: TacticalColors.primaryContainer, size: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOverlay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: TacticalColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: TacticalColors.secondaryContainer, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                const Text(
                  "SYNC: ACTIVE",
                  style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Map<String, dynamic> step1Data) {
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
          SizedBox(
            width: 160,
            child: BlocBuilder<RegistrationBloc, RegistrationState>(
              builder: (context, state) {
                return TacticalButton(
                  text: "NEXT",
                  isLoading: state is RegistrationLoading,
                  onPressed: () {
                    context.read<RegistrationBloc>().add(SubmitVolunteerRegistration({...step1Data, "skills": _selectedSkills}));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
