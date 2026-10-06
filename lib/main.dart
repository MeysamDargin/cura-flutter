import 'package:cura/core/config/app_config.dart';
import 'package:cura/core/theme/app_theme.dart';
import 'package:cura/screen/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.statusBar);

  runApp(const CuraApp());
}

class CuraApp extends StatelessWidget {
  const CuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cura',
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
