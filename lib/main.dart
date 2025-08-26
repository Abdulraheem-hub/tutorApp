/// @context7:feature:main
/// @context7:dependencies:flutter,tutor_pay_app,firebase
/// @context7:pattern:app_entry_point
///
/// Main entry point for TutorPay Flutter app with Material Design 3 and Firebase
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'core/di/dependency_injection.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    print('🚀 Initializing Firebase...');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Initialize Firebase services and wait for auth
    print('🚀 Initializing Firebase services...');
    await FirebaseService.instance.initialize();

    // Initialize dependency injection
    print('🚀 Initializing dependencies...');
    await initializeDependencies();

    print('✅ All services initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize app services: $e');
    // Still run the app but user will see appropriate error messages
  }

  // Quick test to check latest student in Firestore (disabled in production)
  // await _checkLatestStudent();

  // Set system UI overlay style for Material Design 3 Light Theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const TutorPayApp());
}
