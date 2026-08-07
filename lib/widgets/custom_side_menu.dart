import 'dart:ui';
import 'package:flutter/material.dart';

class SideMenuItem {
  final IconData icon;
  final String label;

  const SideMenuItem({
    required this.icon,
    required this.label,
  });
}

class CustomSideMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<SideMenuItem> items;
  final Widget? header;

  const CustomSideMenu({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 280,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color.fromARGB(153, 0, 0, 0) 
                  : const Color.fromARGB(178, 255, 255, 255),
              border: Border(
                right: BorderSide(
                  color: isDark 
                      ? const Color.fromARGB(25, 255, 255, 255) 
                      : const Color.fromARGB(13, 0, 0, 0),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (header != null) ...[
                    header!,
                    Divider(
                      color: isDark 
                          ? const Color.fromARGB(25, 255, 255, 255) 
                          : const Color.fromARGB(25, 0, 0, 0),
                      height: 32,
                    ),
                  ] else ...[
                    const SizedBox(height: 32),
                  ],
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = currentIndex == index;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              onTap(index);
                              Navigator.pop(context); // Close the drawer
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: isSelected
                                    ? theme.primaryColor.withAlpha(38)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? theme.primaryColor.withAlpha(76)
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 24,
                                    color: isSelected
                                        ? theme.primaryColor
                                        : (isDark ? Colors.white70 : Colors.black54),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        letterSpacing: 0.5,
                                        color: isSelected
                                            ? theme.primaryColor
                                            : (isDark ? Colors.white70 : Colors.black87),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 6,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor,
                                        borderRadius: BorderRadius.circular(3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.primaryColor.withAlpha(127),
                                            blurRadius: 8,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
