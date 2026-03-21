import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/tactical_theme.dart';
import '../widgets/tactical_card.dart';
import '../widgets/tactical_text_field.dart';
import '../widgets/tactical_button.dart';
import '../../logic/login/login_bloc.dart';
import '../../logic/login/login_event.dart';
import '../../logic/login/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.text = "default_password";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            final route = state.role == 'CITIZEN' ? '/citizen_dashboard' : '/volunteer_dashboard';
            Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: TacticalColors.errorContainer));
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 60.h),
                  _buildHeader(),
                  SizedBox(height: 48.h),

                  TacticalCard(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      children: [
                        Text(
                          "SECURE ACCESS",
                          style: TextStyle(color: TacticalColors.primary, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 2.0),
                        ),
                        SizedBox(height: 24.h),
                        // UPDATED: Added isNumeric: true and removed spaces from hint
                        TacticalTextField(
                          label: "PHONE NUMBER",
                          hint: "910000000000",
                          icon: Icons.phone_android,
                          controller: _phoneController,
                          isNumeric: true,
                        ),
                        SizedBox(height: 20.h),
                        TacticalTextField(label: "PASSWORD", hint: "••••••••", icon: Icons.lock_outline, controller: _passwordController),
                        SizedBox(height: 32.h),
                        TacticalButton(
                          text: "AUTHENTICATE  →",
                          isLoading: state is LoginLoading,
                          onPressed: () {
                            // UPDATED: Added .trim() to ensure no accidental spaces are submitted
                            context.read<LoginBloc>().add(
                              SubmitLogin(phone: _phoneController.text.trim(), password: _passwordController.text.trim()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                  Text(
                    "OR ESTABLISH NEW MISSION PROFILE",
                    style: TextStyle(color: Colors.white24, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 2.0),
                  ),
                  SizedBox(height: 24.h),

                  _buildPathCard(
                    title: "CITIZEN REGISTRATION",
                    subtitle: "Request immediate assistance",
                    icon: Icons.account_circle,
                    accentColor: TacticalColors.primaryContainer,
                    onTap: () => Navigator.pushNamed(context, '/register_citizen'),
                  ),
                  SizedBox(height: 16.h),
                  _buildPathCard(
                    title: "VOLUNTEER ENROLLMENT",
                    subtitle: "Join the response network",
                    icon: Icons.volunteer_activism,
                    accentColor: TacticalColors.secondaryContainer,
                    onTap: () => Navigator.pushNamed(context, '/register_volunteer'),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "ECHONET",
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 48.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 4.0,
            color: TacticalColors.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "TACTICAL DISASTER RESPONSE NETWORK",
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: Colors.white24),
        ),
      ],
    );
  }

  Widget _buildPathCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TacticalCard(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 24.sp),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.white24, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
