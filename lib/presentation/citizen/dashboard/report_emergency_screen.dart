import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../theme/tactical_theme.dart';
import 'package:frontend/presentation/widgets/tactical_app_bar.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import 'package:frontend/presentation/widgets/tactical_text_field.dart';
import 'package:frontend/presentation/widgets/tactical_button.dart';
import '../../../logic/incident/incident_bloc.dart';

class ReportEmergencyScreen extends StatefulWidget {
  const ReportEmergencyScreen({super.key});

  @override
  State<ReportEmergencyScreen> createState() => _ReportEmergencyScreenState();
}

class _ReportEmergencyScreenState extends State<ReportEmergencyScreen> {
  String _selectedType = 'MEDICAL';
  String _selectedPriority = 'CRITICAL';
  int _peopleAffected = 0;
  bool _allowContact = false;
  String? _capturedImagePath;
  final _descController = TextEditingController();

  final List<Map<String, dynamic>> _emergencyTypes = [
    {"icon": Icons.medical_services, "label": "MEDICAL"},
    {"icon": Icons.local_fire_department, "label": "FIRE"},
    {"icon": Icons.emergency, "label": "RESCUE"},
    {"icon": Icons.house_siding, "label": "FLOOD"},
    {"icon": Icons.inventory_2, "label": "FOOD/SUPPLIES"},
    {"icon": Icons.night_shelter, "label": "SHELTER"},
    {"icon": Icons.psychology, "label": "MENTAL SUPPORT"},
    {"icon": Icons.handyman, "label": "INFRASTRUCTURE"},
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncidentBloc, IncidentState>(
      listener: (context, state) {
        if (state is IncidentSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Emergency Broadcast Successful"), backgroundColor: TacticalColors.secondaryContainer));
          Navigator.pop(context);
        } else if (state is IncidentImagePicked) {
          setState(() => _capturedImagePath = state.path);
        } else if (state is IncidentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: TacticalColors.errorContainer));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: TacticalColors.background,
          appBar: const TacticalAppBar(title: "REPORT EMERGENCY"),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("SELECT EMERGENCY TYPE", isRequired: true),
                const SizedBox(height: 16),
                _buildEmergencyTypeGrid(),
                const SizedBox(height: 40),

                _buildSectionHeader("WHAT IS NEEDED"),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 40),

                _buildSectionHeader("SELECT PRIORITY LEVEL"),
                const SizedBox(height: 16),
                _buildPrioritySelector(),
                const SizedBox(height: 40),

                _buildSectionHeader("LOCATION"),
                const SizedBox(height: 16),
                _buildLocationSection(),
                const SizedBox(height: 40),

                _buildSectionHeader("EVIDENCE"),
                const SizedBox(height: 16),
                _buildEvidenceSection(context),
                const SizedBox(height: 40),

                _buildCounterSection(),
                const SizedBox(height: 24),

                _buildContactToggle(),
                const SizedBox(height: 40),

                TacticalButton(
                  text: "SUBMIT REPORT",
                  icon: Icons.send,
                  isGradient: true,
                  isLoading: state is IncidentLoading,
                  onPressed: () {
                    context.read<IncidentBloc>().add(
                      SubmitIncident(
                        category: _selectedType,
                        description: _descController.text,
                        priority: _selectedPriority,
                        peopleAffected: _peopleAffected,
                        imagePath: _capturedImagePath,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {bool isRequired = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontFamily: 'Space Grotesk', fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        if (isRequired)
          const Text(
            "REQUIRED",
            style: TextStyle(color: TacticalColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
      ],
    );
  }

  Widget _buildEmergencyTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _emergencyTypes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final type = _emergencyTypes[index];
        final isSelected = _selectedType == type['label'];
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type['label']),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isSelected ? TacticalColors.primaryContainer : Colors.transparent, width: 2),
              boxShadow: isSelected ? [BoxShadow(color: TacticalColors.primaryContainer.withOpacity(0.2), blurRadius: 16)] : [],
            ),
            child: TacticalCard(
              padding: EdgeInsets.zero,
              borderRadius: 22,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(type['icon'], color: isSelected ? TacticalColors.primaryContainer : TacticalColors.onSurfaceVariant, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    type['label'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : TacticalColors.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionField() {
    return TacticalTextField(
      label: "SITUATION DETAILS",
      hint: "Briefly describe the situation...",
      icon: Icons.description,
      controller: _descController,
      maxLines: 4,
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: [
        Expanded(child: _buildPriorityButton("CRITICAL", TacticalColors.errorContainer, Colors.white)),
        const SizedBox(width: 12),
        Expanded(child: _buildPriorityButton("MODERATE", TacticalColors.errorContainer, Colors.white)),
        const SizedBox(width: 12),
        Expanded(child: _buildPriorityButton("LOW", TacticalColors.errorContainer, Colors.white)),
      ],
    );
  }

  Widget _buildPriorityButton(String label, Color activeBgColor, Color activeTextColor) {
    bool isSelected = _selectedPriority == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : TacticalColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: isSelected && label == "CRITICAL" ? Border.all(color: Colors.white, width: 1.5) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeTextColor : TacticalColors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return TacticalCard(
      padding: EdgeInsets.zero,
      borderRadius: 32,
      child: Column(
        children: [
          // UPDATED: Replaced Unsplash image with tactical map icon layout
          Container(
            height: 160,
            decoration: const BoxDecoration(
              color: TacticalColors.surfaceContainerHighest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.map, color: Colors.white10, size: 80),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: TacticalColors.primaryContainer.withOpacity(0.2)),
                  ),
                  const Icon(Icons.location_on, color: TacticalColors.primaryContainer, size: 32),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: TacticalColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.my_location, color: TacticalColors.primary, size: 14),
                        SizedBox(width: 8),
                        Text(
                          "CURRENT",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: TacticalColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_location_alt, color: Colors.white, size: 14),
                        SizedBox(width: 8),
                        Text(
                          "EDIT",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceSection(BuildContext context) {
    return Column(
      children: [
        if (_capturedImagePath != null)
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(image: FileImage(File(_capturedImagePath!)), fit: BoxFit.cover),
              border: Border.all(color: TacticalColors.primaryContainer, width: 2),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.white),
                onPressed: () => setState(() => _capturedImagePath = null),
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.read<IncidentBloc>().add(PickIncidentImage(ImageSource.camera)),
                child: _buildDashedButton(Icons.camera_alt, "TAKE PHOTO"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => context.read<IncidentBloc>().add(PickIncidentImage(ImageSource.gallery)),
                child: _buildDashedButton(Icons.upload_file, "UPLOAD"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashedButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: TacticalColors.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: TacticalColors.onSurfaceVariant, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterSection() {
    return TacticalCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "PEOPLE\nAFFECTED",
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_peopleAffected > 0) setState(() => _peopleAffected--);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: TacticalColors.surfaceContainerHighest, shape: BoxShape.circle),
                  child: const Icon(Icons.remove, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                "$_peopleAffected",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () => setState(() => _peopleAffected++),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: TacticalColors.primaryContainer, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactToggle() {
    return TacticalCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ALLOW CONTACT",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
              SizedBox(height: 4),
              Text("Volunteers can reach out directly", style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
          Switch(
            value: _allowContact,
            activeColor: TacticalColors.primaryContainer,
            inactiveTrackColor: Colors.white10,
            onChanged: (val) => setState(() => _allowContact = val),
          ),
        ],
      ),
    );
  }
}
