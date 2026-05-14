// main.dart — ThrottleIQ app entry point.
// Keeps this file minimal: just boot configuration and MaterialApp setup.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait-only for the dashboard experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar so it blends seamlessly with the black background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ThrottleIQApp());
}

class ThrottleIQApp extends StatelessWidget {
  const ThrottleIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ThrottleIQ',

      theme: ThemeData(
        brightness:              Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF060608),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFCC2200),
          surface: Color(0xFF0D0D10),
        ),
        useMaterial3: true,
      ),

      home: const HomeScreen(),
    );
  }
}