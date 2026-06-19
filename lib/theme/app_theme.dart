import 'package:flutter/material.dart';

/// Centralized design tokens so every screen (sign up, login, OTP, success)
/// stays visually consistent and easy to re-theme later.
class AppColors {
  static const Color primaryRed = Color(0xFFE6332A);
  static const Color disabledRed = Color(0xFFF0AFAA);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF6E6E6E);
  static const Color hintGrey = Color(0xFFADADAD);
  static const Color borderGrey = Color(0xFFD9D9D9);
  static const Color success = Color(0xFF1FCB5E);
  static const Color background = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryRed,
    height: 1.2,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 16,
    color: AppColors.hintGrey,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle linkRed = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryRed,
  );

  static const TextStyle footerText = TextStyle(
    fontSize: 15,
    color: AppColors.textDark,
  );
}

class AppSpacing {
  static const double screenPadding = 24.0;
  static const double fieldGap = 20.0;
  static const double smallGap = 8.0;
}

/// Wraps MaterialApp theme data — plug this into your root MaterialApp.
final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primaryRed,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Poppins', // swap for whatever font your Figma uses
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryRed),
);