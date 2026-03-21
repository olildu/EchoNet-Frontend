import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/presentation/widgets/tactical_text_field.dart';
import 'package:frontend/presentation/widgets/tactical_app_bar.dart';
import 'package:frontend/presentation/widgets/tactical_card.dart';
import 'package:frontend/presentation/widgets/tactical_button.dart';
import '../../logic/registration/registration_bloc.dart';
import '../theme/tactical_theme.dart';

class CitizenRegistrationScreen extends StatefulWidget {
  const CitizenRegistrationScreen({super.key});

  @override
  State<CitizenRegistrationScreen> createState() => _CitizenRegistrationScreenState();
}

class _CitizenRegistrationScreenState extends State<CitizenRegistrationScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TacticalAppBar(
        title: "IDENTITY VERIFICATION",
        actions: [
          Icon(Icons.shield, color: TacticalColors.primaryContainer),
          SizedBox(width: 20),
        ],
      ),
      body: BlocConsumer<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationSuccess)
            Navigator.pushNamed(context, '/nominate_guardians');
          else if (state is RegistrationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: TacticalColors.errorContainer));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepIndicator(),
                SizedBox(height: 32.h),
                Text("Establish\nSecure Link.", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42.sp, height: 1.1)),
                SizedBox(height: 12.h),
                Text(
                  "Your phone number is critical for offline SMS emergency routing.",
                  style: TextStyle(color: Colors.white38, fontSize: 16.sp),
                ),
                SizedBox(height: 48.h),

                TacticalTextField(label: "FULL LEGAL NAME", hint: "ENTER FULL NAME", icon: Icons.person, controller: _nameController),
                SizedBox(height: 24.h),

                TacticalTextField(
                  label: "NATIONAL ID / AADHAAR (OPTIONAL)",
                  hint: "XX-XXXX-XXXX-XX",
                  icon: Icons.fingerprint,
                  controller: _idController,
                ),
                SizedBox(height: 24.h),

                // UPDATED: isNumeric added and hint changed
                TacticalTextField(
                  label: "CRITICAL MOBILE NUMBER",
                  hint: "910000000000",
                  icon: Icons.phone_android,
                  controller: _phoneController,
                  isNumeric: true,
                ),

                SizedBox(height: 32.h),
                _buildLocationToggle(),
                SizedBox(height: 48.h),

                TacticalButton(
                  text: "VERIFY COMM LINK  →",
                  isLoading: state is RegistrationLoading,
                  onPressed: () {
                    // UPDATED: Added .trim()
                    context.read<RegistrationBloc>().add(
                      SubmitCitizenRegistration(_nameController.text.trim(), _phoneController.text.trim(), _idController.text.trim()),
                    );
                  },
                ),

                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    "ENCRYPTED SATELLITE UPLINK READY",
                    style: TextStyle(color: Colors.white10, fontSize: 10.sp, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "STEP 1: IDENTITY & COMM LINK",
          style: TextStyle(color: TacticalColors.primary, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(color: TacticalColors.primaryContainer, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationToggle() {
    return TacticalCard(
      padding: EdgeInsets.all(24.w),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
            child: Icon(Icons.location_on, color: TacticalColors.secondaryContainer, size: 20.sp),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Precise Location Access",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Enable for tactical response coordination.",
                  style: TextStyle(fontSize: 13.sp, color: Colors.white38),
                ),
              ],
            ),
          ),
          Switch(value: _locationEnabled, activeColor: TacticalColors.secondaryContainer, onChanged: (val) => setState(() => _locationEnabled = val)),
        ],
      ),
    );
  }
}
