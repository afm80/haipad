import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_shell.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD-OKFvHsvOuhqaKTPpCbY-Qczbx8uhGv4",
        authDomain: "hekaya-1980.firebaseapp.com",
        projectId: "hekaya-1980",
        storageBucket: "hekaya-1980.firebasestorage.app",
        messagingSenderId: "906095389111",
        appId: "1:906095389111:web:fed8a98b9d2159feb2e032",
      ),
    );
  } catch (_) {}

  runApp(const HekayaApp());
}

class HekayaApp extends StatelessWidget {
  const HekayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منصة حكاية | للقراءة والكتابة التفاعلية',
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
