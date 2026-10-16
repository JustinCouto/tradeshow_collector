import 'package:flutter/material.dart';

import '../theme.dart';

/// Full-width green action button that turns gray while [onPressed] is null.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.busy = false,
    this.height = 64,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool busy;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: FilledButton(
          onPressed: busy ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.disabledFill,
            disabledForegroundColor: AppColors.disabledText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontFamily: appFontFamily,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: busy
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.muted,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 22),
                      const SizedBox(width: 10),
                    ],
                    Text(label),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 10),
                      Icon(trailingIcon, size: 22),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
