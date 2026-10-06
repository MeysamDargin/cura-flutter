import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  const AppTheme._();

  static const statusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static ThemeData get dark {
    const seed = Color(0xFF6D28D9);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: statusBar,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
