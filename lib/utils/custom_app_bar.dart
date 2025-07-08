import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearchPressed;
  final bool showSearch;

  const CustomAppBar({super.key, required this.title, this.onSearchPressed, this.showSearch = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEFEFEF), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                  height: 1.25,
                ),
              ),
              if (showSearch)
                GestureDetector(
                  onTap: onSearchPressed,
                  child: const Icon(Icons.search, color: AppColors.primaryText, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(88);
}
