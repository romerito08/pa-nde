import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// ThemeData centralizado que unifica los tokens del design system de Figma:
/// tipografía Outfit (40/32/24/18/16/14, pesos 400/600/700), paleta de
/// colores oficial, radios de 10 px en botones/inputs y 16 px en tarjetas.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.verdeOscuro,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.amarillo,
        onPrimary: Colors.black,
        secondary: AppColors.verdeClaro,
        onSecondary: AppColors.blanco,
        surface: AppColors.verde,
        onSurface: AppColors.blanco,
        error: AppColors.error,
        onError: AppColors.blanco,
      ),
    );

    // Escala tipográfica exacta del frame "Fonts" de Figma (familia Outfit).
    final textTheme = GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
          fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.blanco),
      displayMedium: GoogleFonts.outfit(
          fontSize: 40, fontWeight: FontWeight.w400, color: AppColors.blanco),
      headlineLarge: GoogleFonts.outfit(
          fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.blanco),
      headlineMedium: GoogleFonts.outfit(
          fontSize: 32, fontWeight: FontWeight.w400, color: AppColors.blanco),
      titleLarge: GoogleFonts.outfit(
          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.blanco),
      titleMedium: GoogleFonts.outfit(
          fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.blanco),
      titleSmall: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.blanco),
      bodyLarge: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.blanco),
      bodyMedium: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.blanco),
      bodySmall: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.verdeClaro),
      labelLarge: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
      labelMedium: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.blanco),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.verdeOscuro,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.blanco),
        titleTextStyle: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.blanco),
      ),
      // Botón primario del frame "Buttons": relleno amarillo, texto negro,
      // esquinas de 10 px y altura compacta (35 px en Figma + área táctil).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amarillo,
          foregroundColor: Colors.black,
          disabledBackgroundColor: AppColors.verdeClaro,
          disabledForegroundColor: AppColors.verdeOscuro,
          elevation: 0,
          minimumSize: const Size(67, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blanco,
          side: const BorderSide(color: AppColors.verdeClaro),
          minimumSize: const Size(67, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.amarillo,
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      // Inputs del frame "Buttons → Input": relleno verde, radio 10 px,
      // borde verde claro y foco amarillo.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.verde,
        labelStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.verdeClaro),
        hintStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.verdeClaro),
        errorStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.error),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.verdeClaro),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.amarillo, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.verde,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.verde,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.blanco),
        contentTextStyle:
            GoogleFonts.outfit(fontSize: 16, color: AppColors.blanco),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.verde,
        contentTextStyle:
            GoogleFonts.outfit(fontSize: 14, color: AppColors.blanco),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.verdeClaro),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.amarillo),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.verde),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: AppColors.advertencia.withValues(alpha: 0.15),
        contentTextStyle:
            GoogleFonts.outfit(fontSize: 14, color: AppColors.blanco),
      ),
    );
  }
}
