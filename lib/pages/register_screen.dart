import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;
  double _passwordStrength = 0;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'อีเมลนี้มีการใช้ในระบบแล้ว';
          break;
        case 'invalid-email':
          errorMessage = 'อีเมลไม่ถูกต้อง กรุณาตรวจสอบอีเมลของคุณ';
          break;
        case 'weak-password':
          errorMessage = 'รหัสผ่านอ่อนเกินไป กรุณาใช้รหัสผ่านที่แข็งแกร่งขึ้น';
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

  // ฟังก์ชันตรวจสอบความแข็งแกร่งของรหัสผ่าน
  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = 0;
      } else if (password.length < 6) {
        _passwordStrength = 0.25;
      } else if (password.length < 8) {
        _passwordStrength = 0.5;
      } else if (RegExp(r'(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#\$&*~])')
          .hasMatch(password)) {
        _passwordStrength = 1.0;
      } else {
        _passwordStrength = 0.75;
      }
    });
  }

  // ฟังก์ชันเลือกสีตามความแข็งแกร่งของรหัสผ่าน
  Color _getPasswordStrengthColor(double strength) {
    if (strength <= 0.25) {
      return Colors.red;
    } else if (strength <= 0.5) {
      return Colors.orange;
    } else if (strength <= 0.75) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
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
              // ส่วนซ้าย: แสดงภาพประกอบเมื่อหน้าจอใหญ่เท่านั้น
              if (isLargeScreen)
                Expanded(
                  child: Container(
                    color: Colors.blue.shade100,
                    child: Center(
                      child: Image.asset(
                        'assets/images/finance_image.png', // ใส่เส้นทางของภาพประกอบของคุณที่นี่
                        height: 300, // ปรับขนาดตามความเหมาะสม
                      ),
                    ),
                  ),
                ),
              // ส่วนขวา: ฟอร์มสมัครสมาชิก
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'สมัครสมาชิก',
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
                        onChanged:
                            _checkPasswordStrength, // ตรวจสอบความแข็งแกร่งของรหัสผ่าน
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('ความแข็งแรงของรหัสผ่าน'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value:
                                  _passwordStrength, // ใช้ค่าที่คำนวณจากรหัสผ่านจริง
                              color: _getPasswordStrengthColor(
                                  _passwordStrength), // ไล่สีตามความแข็งแกร่ง
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _register,
                                  child: const Text('สมัครสมาชิก'),
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
                                        builder: (context) => LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('ย้อนกลับ'),
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
