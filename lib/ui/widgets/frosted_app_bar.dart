import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../foundations/colors.dart';

/// Custom AppBar with rounded bottom corners and frosted glass effect
class FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrostedAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 32.0; // More rounded corners
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // More blur for better frosted effect
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? AppColors.white).withOpacity(0.4), // More transparent
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(borderRadius),
              bottomRight: Radius.circular(borderRadius),
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.gray200.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            title: title,
            leading: leading,
            actions: actions,
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            foregroundColor: AppColors.primary,
            centerTitle: true,
          ),
        ),
      ),
    );
  }
}

