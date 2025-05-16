import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:healthbot_app/view/screen/main_screen.dart';
import 'package:healthbot_app/viewmodel/reminder_viewmodel.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/notification_manager.dart';
import 'package:healthbot_app/view/screen/feature/reminder_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Initialize notifications
  await NotificationService().initialize();
  await NotificationManager().initialize();

  // Configure Firebase Functions
  FirebaseFunctions.instance.httpsCallable('rag_function');

  // Create ReminderViewModel and load reminders
  final reminderViewModel = ReminderViewModel();
  await reminderViewModel.loadReminders();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthBot',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      navigatorKey: navigatorKey, // Add this
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(),
        '/reminder': (context) => const ReminderScreen(), // Add your ReminderScreen
      },
      debugShowCheckedModeBanner: false,
    );
  }
}