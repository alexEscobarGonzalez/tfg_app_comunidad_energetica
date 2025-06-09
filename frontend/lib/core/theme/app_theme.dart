import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Fondo principal de la aplicación - grisáceo/azulado suave
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.appBackground,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnPrimary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondaryDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
        outline: AppColors.border,
        outlineVariant: AppColors.divider,
      ),
      
      // AppBar Theme - Optimizado para web
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle,
        toolbarHeight: 40, // Reducido drásticamente de 50
      ),
      
      // Card Theme - Optimizado para web
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0.5, // Reducido drásticamente de 1
        shadowColor: AppColors.cardShadow.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Reducido drásticamente de 8
        ),
        margin: const EdgeInsets.all(2), // Reducido drásticamente de 4
      ),
      
      // Elevated Button Theme - Optimizado para web
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0.5, // Reducido drásticamente de 1
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reducido drásticamente
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3), // Reducido drásticamente de 6
          ),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(60, 24), // Reducido drásticamente de Size(80, 32)
        ),
      ),
      
      // Outlined Button Theme - Optimizado para web
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 0.5), // Reducido
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reducido drásticamente
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3), // Reducido drásticamente de 6
          ),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(60, 24), // Reducido drásticamente de Size(80, 32)
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reducido drásticamente
          minimumSize: const Size(40, 20), // Reducido drásticamente de Size(60, 28)
        ),
      ),
      
      // Input Decoration Theme - Optimizado para web
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3), // Reducido drásticamente de 6
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(color: AppColors.primary, width: 1), // Reducido de 1.5
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reducido drásticamente
        hintStyle: AppTextStyles.bodySecondary,
        labelStyle: AppTextStyles.bodyMedium,
        isDense: true,
      ),
      
      // Floating Action Button Theme - Optimizado para web
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 1, // Reducido drásticamente de 2
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)), // Reducido drásticamente de 16
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 2, // Reducido drásticamente de 4
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.3, // Reducido drásticamente de 0.5
        space: 0.3, // Reducido drásticamente de 0.5
      ),
      
      // Chip Theme - Optimizado para web
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
        labelStyle: AppTextStyles.bodySmall,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Reducido drásticamente
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Reducido drásticamente de 12
        ),
      ),
      
      // List Tile Theme - Optimizado para web
      listTileTheme: const ListTileThemeData(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Reducido drásticamente
        minVerticalPadding: 2, // Reducido drásticamente de 4
        titleTextStyle: AppTextStyles.bodyMedium,
        subtitleTextStyle: AppTextStyles.bodySmall,
      ),
      
      // Tab Bar Theme - Optimizado para web
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.bodyMedium,
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      
      // Dialog Theme - Optimizado para web
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Reducido drásticamente de 8
        ),
        titleTextStyle: AppTextStyles.headline4,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
      
      // Snack Bar Theme - Optimizado para web
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3), // Reducido drásticamente de 6
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 