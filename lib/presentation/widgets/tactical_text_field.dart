import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // NEW IMPORT
import '../theme/tactical_theme.dart';

class TacticalTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPrimary;
  final int maxLines;
  final bool isNumeric; // NEW: Flag to restrict to numbers only

  const TacticalTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPrimary = false,
    this.maxLines = 1,
    this.isNumeric = false, // Defaults to false so it won't break other text fields
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isPrimary ? TacticalColors.primaryContainer : Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          // NEW: Enforce number keyboard and strip non-digits if isNumeric is true
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 ? Icon(icon, color: isPrimary ? TacticalColors.primaryContainer : Colors.white24) : null,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white12),
            filled: true,
            fillColor: TacticalColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
