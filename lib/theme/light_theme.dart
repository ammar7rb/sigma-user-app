import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Color _primaryColor = const Color(0xFF075ACB);
Color _secondaryColor = const Color(0xFFF58300);

ThemeData light({Color? primaryColor, Color? secondaryColor}) => ThemeData(
      fontFamily: 'Cairo',
      primaryColor: _primaryColor,
      brightness: Brightness.light,
      highlightColor: Colors.white,
      hintColor: const Color(0xFF5B6A80), //Border Color
      splashColor: Colors.transparent,
      cardColor: Colors.white,

      scaffoldBackgroundColor: const Color(0xFFF6F8FC),

      textTheme: TextTheme(
        bodyLarge:
            const TextStyle(color: Color(0xFF222324)), // Text color primary
        bodyMedium: TextStyle(color: _primaryColor), // Text color Secondary
        bodySmall:
            const TextStyle(color: Color(0xFF5B6A80)), // Text color Light grey

        titleMedium: const TextStyle(color: Color(0xFF656566)),
      ),

      colorScheme: ColorScheme.light(
        primary: _primaryColor, // Primary Color
        secondary: _secondaryColor, // Secondary Color
        tertiary: const Color(0xFFFFBB38), // Warning Color
        tertiaryContainer: const Color(0xFFADC9F3),
        onTertiaryContainer: const Color(0xFF172942), // Success Color
        onPrimary: Colors.white,
        surface: Colors.white,
        onSecondary: const Color(0xFF172942),
        error: const Color(0xFFB3261E), // Readable error text on light surfaces
        onSecondaryContainer: const Color(0xFF172942),
        outline: const Color(0xff5C8FFC), // Info Color
        onTertiary: const Color(0xFF172942),
        shadow: const Color(0xFF66717C),

        primaryContainer: const Color(0xFFEDF2FB),
        onPrimaryContainer: const Color(0xFF172942),
        secondaryContainer: const Color(0xFFE9EEF4),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6F8FC),
        foregroundColor: Color(0xFF15243A),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(color: Color(0xFF172942)),
      dividerColor: const Color(0xFFE5EAF2),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Color(0xFFE5F0FF),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
      }),
    );
