import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';

class TacticalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const TacticalAppBar({super.key, required this.title, this.actions, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: TacticalColors.primaryContainer),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: TacticalColors.primary,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
