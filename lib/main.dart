import 'package:flutter/material.dart';
import 'package:next_sprints/pages/addProject.dart';
import 'package:next_sprints/pages/login.dart';
import 'package:next_sprints/pages/projects.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next Sprints',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
          future: _checkLoginStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.data == true) {
              return Projects();
            } else {
              return Login();
            }
          },
        ),
        '/login': (context) => Login(),
        '/projects': (context) => Projects(),
        '/AddProject': (context) => Addproject(),
        
      },
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }
}
