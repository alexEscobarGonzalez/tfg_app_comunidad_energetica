import 'package:flutter/material.dart';

class AppColors {
  // Colores primarios (verde energético)
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);
  
  // Colores secundarios (azul tecnológico)
  static const Color secondary = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF63A4FF);
  static const Color secondaryDark = Color(0xFF004BA0);
  
  // Colores de energía
  static const Color solar = Color(0xFFFFA726);
  static const Color wind = Color(0xFF29B6F6);
  static const Color battery = Color(0xFF66BB6A);
  static const Color grid = Color(0xFF8D6E63);
  
  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Colores neutros - Modificados para fondo grisáceo/azulado suave
  static const Color background = Color(0xFFF5F7FA); // Fondo grisáceo-azulado muy suave
  static const Color surface = Color(0xFFFFFFFF); // Superficies blancas para contraste
  static const Color cardBackground = Color(0xFFFFFFFF); // Cards blancos sobre el fondo
  static const Color appBackground = Color(0xFFF0F2F5); // Fondo aún más suave para áreas principales
  
  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Colores de bordes y divisores
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  
  // Gradientes
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient energyGradient = LinearGradient(
    colors: [solar, wind],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  
  // Sombras - Reducidas para UI más compacta
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x12000000), // Reducido de 0x1A000000
    offset: Offset(0, 1), // Reducido de Offset(0, 2)
    blurRadius: 4, // Reducido de 8
    spreadRadius: 0,
  );
  
  static const BoxShadow elevatedShadow = BoxShadow(
    color: Color(0x18000000), // Reducido de 0x1F000000
    offset: Offset(0, 2), // Reducido de Offset(0, 4)
    blurRadius: 8, // Reducido de 16
    spreadRadius: 0,
  );
} 