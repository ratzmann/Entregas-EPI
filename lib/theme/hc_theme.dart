import 'package:material_ui/material_ui.dart';

/// Identidade visual herdada do site da HC Assessoria:
/// azul da marca como único acento sobre neutros frios, títulos em Archivo,
/// rótulos condensados em caixa-alta (Oswald) e texto corrido em Public Sans.
class HcColors {
  HcColors._();

  static const bg = Color(0xFFF2F6F9);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFE7EEF3);
  static const ink = Color(0xFF0A1A26);
  static const inkMuted = Color(0xFF4F6373);
  static const line = Color(0xFFD6E1E8);
  static const brand = Color(0xFF00ADEF);
  static const brandInk = Color(0xFF007FB3);
  static const navy = Color(0xFF0A1A26);
  static const amber = Color(0xFFF2A900);
  static const danger = Color(0xFFC62828);
  static const success = Color(0xFF1E8E5A);
}

class HcFonts {
  HcFonts._();

  static const headline = 'Archivo';
  static const label = 'Oswald';
  static const body = 'PublicSans';
}

class HcText {
  HcText._();

  /// Rótulo "placa de obra": condensado, caixa-alta, espaçado.
  static const eyebrow = TextStyle(
    fontFamily: HcFonts.label,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 1.6,
    color: HcColors.brandInk,
  );
}

ThemeData buildHcTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: HcColors.brandInk,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD5F1FD),
    onPrimaryContainer: HcColors.navy,
    secondary: HcColors.brand,
    onSecondary: HcColors.navy,
    tertiary: HcColors.amber,
    onTertiary: HcColors.navy,
    error: HcColors.danger,
    onError: Colors.white,
    surface: HcColors.surface,
    onSurface: HcColors.ink,
    onSurfaceVariant: HcColors.inkMuted,
    surfaceContainerLowest: HcColors.surface,
    surfaceContainerLow: HcColors.bg,
    surfaceContainer: HcColors.surface2,
    surfaceContainerHigh: HcColors.surface2,
    outline: HcColors.line,
    outlineVariant: HcColors.line,
  );

  const headline = TextStyle(
    fontFamily: HcFonts.headline,
    fontWeight: FontWeight.w800,
    color: HcColors.ink,
    letterSpacing: -0.2,
  );

  final labelButton = const TextStyle(
    fontFamily: HcFonts.label,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    letterSpacing: 0.9,
  );

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: HcColors.line, width: 1.2),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: HcColors.bg,
    fontFamily: HcFonts.body,
    textTheme: const TextTheme(
      headlineLarge: headline,
      headlineMedium: headline,
      headlineSmall: headline,
      titleLarge: TextStyle(
        fontFamily: HcFonts.headline,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: HcColors.ink,
      ),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14.5, height: 1.45),
      bodySmall: TextStyle(fontSize: 12.5, color: HcColors.inkMuted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: HcColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: HcFonts.headline,
        fontWeight: FontWeight.w700,
        fontSize: 19,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: HcColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: HcColors.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: HcColors.surface,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: HcColors.brand, width: 2),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: HcColors.danger, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: HcColors.brandInk,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        textStyle: labelButton,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: HcColors.ink,
        minimumSize: const Size.fromHeight(52),
        textStyle: labelButton,
        side: const BorderSide(color: HcColors.line, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: HcColors.brand,
      foregroundColor: HcColors.navy,
      extendedTextStyle: labelButton,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: HcColors.surface,
      indicatorColor: const Color(0xFFD5F1FD),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: HcFonts.label,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.6,
          color: states.contains(WidgetState.selected)
              ? HcColors.ink
              : HcColors.inkMuted,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: HcColors.surface,
      selectedColor: const Color(0xFFD5F1FD),
      side: const BorderSide(color: HcColors.line),
      labelStyle: const TextStyle(fontSize: 13, color: HcColors.ink),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: const DividerThemeData(color: HcColors.line, space: 1),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: HcColors.navy,
    ),
  );
}
