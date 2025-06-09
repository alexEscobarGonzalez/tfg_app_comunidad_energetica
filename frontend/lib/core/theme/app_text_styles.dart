import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Tipografía web-friendly
  static const String _webFontFamily = 'Segoe UI';
  static const List<String> _fontFallbacks = [
    'Segoe UI',
    '-apple-system',
    'BlinkMacSystemFont',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif'
  ];

  // Color grisáceo oscuro para títulos de tabs
  static const Color _tabTitleColor = Color(0xFF2C3E50); // Grisáceo oscuro elegante
  static const Color _tabSubtitleColor = Color(0xFF34495E); // Grisáceo medio

  // Títulos principales - Con tipografía web
  static const TextStyle headline1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  static const TextStyle headline4 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );

  static const TextStyle tabSectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: _tabTitleColor,
    height: 1.3,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
    letterSpacing: -0.3,
  );

  static const TextStyle tabDescription = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _tabSubtitleColor,
    height: 1.5,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  // Texto del cuerpo - Con tipografía web
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  // Botones
  static const TextStyle button = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  // Subtítulos y etiquetas
  static const TextStyle subtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  // Estilos específicos para la app
  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  static const TextStyle statisticValue = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    height: 1.2,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  static const TextStyle statisticLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
  
  // Estilo para títulos en AppBar (texto blanco)
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.3,
    fontFamily: _webFontFamily,
    fontFamilyFallback: _fontFallbacks,
  );
} 