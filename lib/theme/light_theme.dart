import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  secondaryHeaderColor: AppColors.secondary,
  scaffoldBackgroundColor: AppColors.background,
  cardColor: AppColors.card,
  dividerColor: AppColors.divider,
  hintColor: AppColors.textLight,
  disabledColor: AppColors.textLight,
  shadowColor: Colors.black.withValues(alpha: 0.05),
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.primary,
    surface: AppColors.card,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSurface: AppColors.textDark,
  ),
  // White app bar with black centered title + back arrow (Ananda v1.67 style).
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.textDark,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w700,
      fontSize: Dimensions.fontSizeExtraLarge,
      color: AppColors.textDark,
    ),
    iconTheme: IconThemeData(color: AppColors.textDark),
    actionsIconTheme: IconThemeData(color: AppColors.textDark),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  cardTheme: const CardThemeData(
    color: AppColors.card,
    surfaceTintColor: Colors.white,
    elevation: 0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.card,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textMedium,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  dividerTheme: const DividerThemeData(
    thickness: 0.5,
    color: AppColors.divider,
    space: 1,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  // Clean underline fields (Ananda sign-in style).
  inputDecorationTheme: const InputDecorationTheme(
    filled: false,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 12),
    border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 1.6)),
  ),
);
