import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // NEW
import '../theme/tactical_theme.dart';

class TacticalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding; // Changed to nullable to apply dynamic default
  final Color color;
  final double borderRadius;
  final BorderSide? leftBorder;

  const TacticalCard({
    super.key,
    required this.child,
    this.padding,
    this.color = TacticalColors.surfaceContainerLow,
    this.borderRadius = 32.0,
    this.leftBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Dynamic padding: 24.w scales based on screen width
      padding: padding ?? EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius.r), // Scaled Radius
        border: leftBorder != null ? Border(left: leftBorder!) : null,
      ),
      child: child,
    );
  }
}
