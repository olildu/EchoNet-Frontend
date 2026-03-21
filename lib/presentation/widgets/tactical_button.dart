import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // NEW
import '../theme/tactical_theme.dart';

class TacticalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isGradient;
  final Color? backgroundColor;
  final Color textColor;

  const TacticalButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isGradient = true,
    this.backgroundColor,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h), // Scaled Height
        decoration: BoxDecoration(
          color: isGradient ? null : (backgroundColor ?? TacticalColors.surfaceContainerLow),
          gradient: isGradient ? TacticalColors.sosGradient : null,
          borderRadius: BorderRadius.circular(32.r), // Scaled Radius
          boxShadow: isGradient
              ? [BoxShadow(color: TacticalColors.primaryContainer.withOpacity(0.3), blurRadius: 20.r, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: const CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[Icon(icon, color: textColor, size: 18.sp), SizedBox(width: 12.w)], // Scaled Icon & Space
                    Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12.sp, // Scaled Font Size
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
