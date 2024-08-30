// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:next_sprints/pages/detailProject.dart';
import 'package:next_sprints/pages/login.dart';
import 'package:next_sprints/shared/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Projects extends StatefulWidget {
  const Projects({super.key});

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  List<dynamic> projects = [];
  String? token;  // Declare a variable to store the token

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchProjects();
  }

  Future<void> _loadTokenAndFetchProjects() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    
    if (token != null) {
      await fetchProjects();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  Future<void> fetchProjects() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.155:8000/api/projects/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Decode the response body with utf8.decode
        final decodedResponse = utf8.decode(response.bodyBytes);
        setState(() {
          projects = json.decode(decodedResponse);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project Loading Failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarBlue,
        title: Text("Projects", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("The Projects", style: TextStyle(fontSize: 20)), // Fixed typo
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blueAccent),
                  onPressed: () {
                    Navigator.pushNamed(context, '/AddProject');
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(15.0),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        top: BorderSide(
                          color: BTNBlue,
                          width: 3,
                        ),
                        left: BorderSide(
                          color: BTNBlue,
                          width: 3,
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        projects[index]['name'] ?? 'No name',
                        style: TextStyle(fontSize: 20),
                      ),
                      subtitle: Text(
                        projects[index]['description'] ?? 'No description',
                        maxLines: 3,  // Limit the number of lines
                        overflow: TextOverflow.ellipsis,  // Show ellipsis if text is too long
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailProject(project: projects[index])),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token'); // Clear token from secure storage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }
}
