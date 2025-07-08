import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Color? spinnerColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.loading = false,
    this.style,
    this.spinnerColor,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  });

  ButtonStyle get _defaultStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.green,
    foregroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
      side: const BorderSide(color: AppColors.green),
    ),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    elevation: 2,
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: style ?? _defaultStyle,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      child: loading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(spinnerColor ?? AppColors.white),
              ),
            )
          : child,
    );
  }
}
