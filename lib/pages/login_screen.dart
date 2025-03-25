import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'finance.dart';
import '../database/database_helper.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FinanceScreen(
            dbHelper: DatabaseHelper(),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'ไม่พบผู้ใช้นี้ในระบบ กรุณาลงทะเบียนก่อน';
          break;
        case 'invalid-login-credentials':
          errorMessage = 'รหัสผ่านไม่ถูกต้อง กรุณาลองใหม่';
          break;
        case 'invalid-email':
          errorMessage = 'อีเมลไม่ถูกต้อง กรุณาตรวจสอบอีเมลของคุณ';
          break;
        case 'missing-password':
          errorMessage = 'กรุณากรอกรหัสผ่าน';
          break;
        case 'too-many-requests':
          errorMessage =
              'คุณพยายามล็อกอินหลายครั้งเกินไป กรุณารอสักครู่แล้วลองใหม่';
          break;
        default:
          errorMessage = 'เกิดข้อผิดพลาด: ${e.code}';
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาดบางอย่าง: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เกิดข้อผิดพลาด'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ตกลง'),
              style: TextButton.styleFrom(
                primary: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ตรวจสอบความกว้างของหน้าจอ
          bool isLargeScreen = constraints.maxWidth > 600;

          return Row(
            children: [
              // ส่วนซ้าย แสดงภาพประกอบ ถ้าหน้าจอกว้างพอ
              if (isLargeScreen)
                Expanded(
                  child: Container(
                    color: Colors.blue.shade100,
                    child: Center(
                      child: Image.asset(
                        'assets/images/finance_image.png', // ใส่ภาพประกอบของคุณที่นี่
                        height: 300, // ปรับขนาดตามความเหมาะสม
                      ),
                    ),
                  ),
                ),
              // ส่วนขวา แสดงฟอร์มล็อกอิน
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ยินดีต้อนรับ!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        cursorColor: Colors.grey, // เปลี่ยนสี cursor เป็นสีเทา
                        decoration: const InputDecoration(
                          labelText: 'อีเมลของคุณ',
                          labelStyle: TextStyle(
                              color: Colors.grey), // เปลี่ยนสี label เป็นสีเทา
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2.0), // เส้นขอบเมื่อโฟกัส
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.5), // เส้นขอบเมื่อไม่ได้โฟกัส
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        cursorColor: Colors.grey, // เปลี่ยนสี cursor เป็นสีเทา
                        decoration: InputDecoration(
                          labelText: 'สร้างรหัสผ่าน',
                          labelStyle: const TextStyle(
                              color: Colors.grey), // เปลี่ยนสี label เป็นสีเทา
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2.0), // เส้นขอบเมื่อโฟกัส
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.5), // เส้นขอบเมื่อไม่ได้โฟกัส
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors
                                  .grey, // เปลี่ยนสีไอคอน toggle เป็นสีเทา
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _login,
                                  child: const Text('เข้าสู่ระบบ'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16),
                                    primary: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('สร้างบัญชีผู้ใช้'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16),
                                    primary: Colors.blue,
                                    side: const BorderSide(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
