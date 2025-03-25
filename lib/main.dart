import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login_screen.dart';
import 'pages/finance.dart'; // นำเข้าไฟล์จัดการการเงิน
import 'package:firebase_core/firebase_core.dart';
import 'package:listmember/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBGtRPwp5zTDm7ONeJZaeV_Qkbo3rgcALc",
      appId: "1:222877954282:android:af26517f02f0be51cba793",
      messagingSenderId: "",
      projectId: "myapp-b8f1d",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance Management',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const AuthGate(),
    );
  }
}

// ตรวจสอบสถานะการล็อกอิน
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return FinanceScreen(dbHelper: DatabaseHelper());
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
