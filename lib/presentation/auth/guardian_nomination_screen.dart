import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/logic/registration/registration_bloc.dart';
import '../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_text_field.dart';
import 'package:frontend/presentation/widgets/tactical_app_bar.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import 'package:frontend/presentation/widgets/tactical_button.dart';

class GuardianNominationScreen extends StatefulWidget {
  const GuardianNominationScreen({super.key});

  @override
  State<GuardianNominationScreen> createState() => _GuardianNominationScreenState();
}

class _GuardianNominationScreenState extends State<GuardianNominationScreen> {
  final _primaryNameController = TextEditingController();
  final _primaryPhoneController = TextEditingController();
  final _secondaryNameController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      listener: (context, state) {
        if (state is RegistrationSuccess && state.userId != "volunteer_complete") {
          Navigator.pushNamedAndRemoveUntil(context, '/citizen_dashboard', (route) => false);
        } else if (state is RegistrationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: TacticalColors.errorContainer));
        }
      },
      child: Scaffold(
        appBar: const TacticalAppBar(title: "IDENTITY VERIFICATION"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(),
              const SizedBox(height: 32),
              Text("Nominate\nGuardians.", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42, height: 1.1)),
              const SizedBox(height: 16),
              const Text(
                "These contacts will be automatically alerted via encrypted SMS if you broadcast an SOS.",
                style: TextStyle(color: Colors.white38, fontSize: 16),
              ),
              const SizedBox(height: 40),

              _buildContactCard(
                title: "PRIMARY EMERGENCY CONTACT",
                accentColor: TacticalColors.primary,
                nameController: _primaryNameController,
                phoneController: _primaryPhoneController,
                nameHint: "e.g. Sarah Jenkins",
              ),

              const SizedBox(height: 24),

              _buildContactCard(
                title: "SECONDARY CONTACT",
                accentColor: Colors.white24,
                nameController: _secondaryNameController,
                phoneController: _secondaryPhoneController,
                isOptional: true,
              ),

              const SizedBox(height: 32),
              _buildInfoBox(),
              const SizedBox(height: 48),

              BlocBuilder<RegistrationBloc, RegistrationState>(
                builder: (context, state) {
                  return TacticalButton(
                    text: "SECURE CONTACTS  →",
                    isLoading: state is RegistrationLoading,
                    onPressed: () {
                      final currentState = context.read<RegistrationBloc>().state;
                      if (currentState is RegistrationSuccess) {
                        // UPDATED: Added .trim() to names and phones
                        context.read<RegistrationBloc>().add(
                          SubmitEmergencyContacts(currentState.userId, [
                            {"name": _primaryNameController.text.trim(), "phone": _primaryPhoneController.text.trim(), "is_primary": true},
                            if (_secondaryNameController.text.trim().isNotEmpty)
                              {"name": _secondaryNameController.text.trim(), "phone": _secondaryPhoneController.text.trim(), "is_primary": false},
                          ]),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "STEP 2: EMERGENCY NETWORK",
          style: TextStyle(color: TacticalColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(2, (index) {
            bool isCompleted = index == 0;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index == 1 ? 0 : 8),
                decoration: BoxDecoration(
                  color: isCompleted ? TacticalColors.primaryContainer : TacticalColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required String title,
    required Color accentColor,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    String nameHint = "Enter name",
    bool isOptional = false,
  }) {
    return TacticalCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
              const Spacer(),
              if (isOptional)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                  child: const Text(
                    "OPTIONAL",
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white38),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          TacticalTextField(label: "GUARDIAN FULL NAME", hint: nameHint, icon: Icons.person, controller: nameController),
          const SizedBox(height: 20),
          // UPDATED: Added isNumeric: true and changed hint
          TacticalTextField(label: "MOBILE SECURE LINE", hint: "15550000000", icon: Icons.phone, controller: phoneController, isNumeric: true),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: TacticalColors.secondaryContainer, size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "Contacts will receive a verification link once you complete registration. They must accept the request to be active in your mesh network.",
              style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
