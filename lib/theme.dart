import 'package:flutter/material.dart';

abstract final class AppColors {
  static const green = Color(0xFF52A51F);
  static const brightGreen = Color(0xFF76CF3C);
  static const greenText = Color(0xFF3F8F14);
  static const greenTint = Color(0xFFECF6E4);
  static const navy = Color(0xFF1E2433);
  static const navyCard = Color(0xFF1F2536);
  static const body = Color(0xFF3B4150);
  static const muted = Color(0xFF8A909B);
  static const border = Color(0xFFDCDFE4);
  static const divider = Color(0xFFECEDEF);
  static const background = Color(0xFFF8F8F6);
  static const disabledFill = Color(0xFFE4E6EA);
  static const disabledText = Color(0xFF959AA3);
  static const error = Color(0xFFC2410C);
  static const errorBorder = Color(0xFFE0845A);
  static const errorFill = Color(0xFFFFF6F1);
}

const appFontFamily = 'PlusJakartaSans';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: appFontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      error: AppColors.error,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
  );

  OutlineInputBorder outline(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.navy,
      displayColor: AppColors.navy,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.green,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hoverColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 17),
      enabledBorder: outline(AppColors.border),
      focusedBorder: outline(AppColors.green, 1.5),
      errorBorder: outline(AppColors.errorBorder),
      focusedErrorBorder: outline(AppColors.errorBorder, 1.5),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
