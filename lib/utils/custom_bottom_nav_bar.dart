import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

enum BottomNavTab { dashboard, watch, mediaLibrary, more }

class CustomBottomNavBar extends StatelessWidget {
  final BottomNavTab currentTab;
  final Function(BottomNavTab) onTabChanged;

  const CustomBottomNavBar({super.key, required this.currentTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: AppColors.navigationBackground,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(27), topRight: Radius.circular(27)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(BottomNavTab.dashboard, 'Dashboard', 'assets/icons/dashboard_icon.svg'),
          _buildNavItem(BottomNavTab.watch, 'Watch', 'assets/icons/watch_icon.svg'),
          _buildNavItem(BottomNavTab.mediaLibrary, 'Media Library', 'assets/icons/media_library_icon.svg'),
          _buildNavItem(BottomNavTab.more, 'More', 'assets/icons/more_icon.svg'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BottomNavTab tab, String label, String icon) {
    final isActive = currentTab == tab;
    final textColor = isActive ? AppColors.white : AppColors.inactiveTab;
    final fontWeight = isActive ? FontWeight.w700 : FontWeight.w400;

    return GestureDetector(
      onTap: () => onTabChanged(tab),
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            SizedBox(height: 18, width: 18, child: SvgPicture.asset(icon, width: 24, height: 24, color: textColor)),
            const SizedBox(height: 7),
            // Label
            Text(
              label,
              style: GoogleFonts.roboto(fontSize: 10, fontWeight: fontWeight, color: textColor, letterSpacing: 0.1),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
