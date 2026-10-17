import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'app_shell.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    FirebaseAuth.instance.authStateChanges().listen(AuthService.syncProfile);
  } catch (_) {}

  runApp(const HaipadApp());
}

class HaipadApp extends StatelessWidget {
  const HaipadApp({super.key});

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
      home: const AppShell(),
    );
  }
}
