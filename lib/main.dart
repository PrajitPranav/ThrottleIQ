
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/home/home_screen.dart';
import 'services/trip_storage_service.dart';
import 'services/settings_service.dart';
import 'services/profile_service.dart';
import 'services/garage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  await Future.wait([
    TripStorageService().loadTrips(),
    SettingsService().loadSettings(),
    ProfileService().loadProfile(),
    GarageService().loadGarage(),
  ]);

  // Portrait-only for the dashboard experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  
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
