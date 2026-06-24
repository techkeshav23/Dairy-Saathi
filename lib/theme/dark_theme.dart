import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  secondaryHeaderColor: AppColors.secondary,
  scaffoldBackgroundColor: AppColors.darkBackground,
  cardColor: AppColors.darkCard,
  hintColor: AppColors.textLight,
  shadowColor: Colors.black.withValues(alpha: 0.3),
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.primary,
    surface: AppColors.darkCard,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkCard,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w700,
      fontSize: Dimensions.fontSizeExtraLarge,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  cardTheme: const CardThemeData(
    color: AppColors.darkCard,
    surfaceTintColor: AppColors.darkCard,
    elevation: 0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkCard,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: Colors.white70,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  dividerTheme: const DividerThemeData(
    thickness: 0.5,
    color: AppColors.darkBorder,
    space: 1,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: false,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 12),
    border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 1.6)),
  ),
);
