import 'package:flutter/material.dart';
import '../theme/tactical_theme.dart';

class TacticalNavItem {
  final String label;
  final IconData icon;
  final bool hasNotification;

  TacticalNavItem({required this.label, required this.icon, this.hasNotification = false});
}

class TacticalBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<TacticalNavItem> items;
  final Function(int) onItemSelected;

  const TacticalBottomNav({super.key, required this.selectedIndex, required this.items, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: TacticalColors.background,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () => onItemSelected(index),
              child: isSelected
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        // Uses the primary orange highlight or gradient depending on your preference
                        color: TacticalColors.primaryContainer,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, color: Colors.black, size: 20),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(item.icon, color: Colors.white38, size: 24),
                            if (item.hasNotification)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: TacticalColors.primaryContainer, shape: BoxShape.circle),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                        ),
                      ],
                    ),
            );
          }),
        ),
      ),
    );
  }
}
