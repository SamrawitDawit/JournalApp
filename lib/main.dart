import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:journal_app/auth.dart';
import 'package:journal_app/add_journal.dart';
import 'firebase_options.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(MyApp());
  } catch (e) {
    debugPrint("Error initializing Firebase: $e");
  }
  AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
  final InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthScreen(),
      debugShowCheckedModeBanner: false, // To disable the debug banner
    );
  }
}
