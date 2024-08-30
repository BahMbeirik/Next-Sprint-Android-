import 'package:flutter/material.dart';
import 'package:next_sprints/pages/register.dart';
import 'package:next_sprints/pages/projects.dart';
import 'package:next_sprints/shared/colors.dart';
import 'package:next_sprints/shared/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
  final response = await http.post(
    Uri.parse('http://192.168.1.155:8000/api/token/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': _usernameController.text,
      'password': _passwordController.text,
    }),
  );

  // طباعة معلومات الاستجابة للتشخيص
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);

    // التحقق من وجود access token في الاستجابة
    if (jsonResponse.containsKey('access') && jsonResponse['access'] != null) {
      final token = jsonResponse['access'];

      // حفظ التوكن في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // توجيه المستخدم إلى صفحة المشاريع
      Navigator.pushReplacementNamed(context, '/projects');
    } else {
      // إذا لم يكن هناك access token في الاستجابة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تسجيل الدخول فشل، التوكن مفقود')),
      );
    }
  } else {
    // التعامل مع الأخطاء
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل تسجيل الدخول')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(33.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 64),
                TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: decorationTextField.copyWith(
                    hintText: 'Enter Your Email:',
                  ),
                ),
                const SizedBox(height: 33),
                TextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  decoration: decorationTextField.copyWith(
                    hintText: 'Enter Your Password:',
                  ),
                ),
                const SizedBox(height: 33),
                ElevatedButton(
                  onPressed: _login,
                  child: Text(
                    "Sign in",
                    style: TextStyle(color: Colors.white, fontSize: 19),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(BTNBlue),
                    padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 33),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Register()),
                        );
                      },
                      child: Text('Sign up', style: TextStyle(color: Colors.black, fontSize: 20)),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
