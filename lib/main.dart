import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_service.dart';
import 'app_shell.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? initError;
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCCvMeXTfRpm6o_qyGTg76lxTgQolDfdAI",
        authDomain: "haipad.firebaseapp.com",
        projectId: "haipad",
        storageBucket: "haipad.firebasestorage.app",
        messagingSenderId: "949476046493",
        appId: "1:949476046493:web:85d0147fa2e87cc21d0674",
      ),
    );
    AuthService.init();
  } catch (e) {
    initError = e;
  }

  runApp(HaipadApp(initError: initError));
}

class HaipadApp extends StatelessWidget {
  final Object? initError;
  const HaipadApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'haipad | للقراءة والكتابة التفاعلية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand500),
        scaffoldBackgroundColor: AppColors.slate50,
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: initError == null
          ? const AppShell()
          : Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('تعذّرت تهيئة Firebase.\n$initError',
                      textAlign: TextAlign.center, style: cairo(14)),
                ),
              ),
            ),
    );
  }
}
