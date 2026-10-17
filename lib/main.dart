import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

  runApp(const HekayaApp());
}

class HekayaApp extends StatelessWidget {
  const HekayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حكاية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
