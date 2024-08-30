import 'package:flutter/material.dart';
import 'package:next_sprints/pages/projects.dart';
import 'package:next_sprints/shared/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Addproject extends StatefulWidget {
  const Addproject({super.key});

  @override
  State<Addproject> createState() => _AddprojectState();
}

class _AddprojectState extends State<Addproject> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addProject() async {
    final String name = _nameController.text;
    final String description = _descriptionController.text;

    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final token = await _getToken();
    final response = await http.post(
      Uri.parse('http://192.168.1.155:8000/api/projects/'), 
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'description': description,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project added successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Projects()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add project')),
      );
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarBlue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Add Project",
          style: TextStyle(color: Colors.white),
        ),
      ),
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              width: 350,
              height: 450,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(
                    color: BTNBlue,
                    width: 3,
                  ),
                  right: BorderSide(
                    color: BTNBlue,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 30,),
                  Text("Add new Project",style: TextStyle(fontSize: 20),),
                  SizedBox(height: 60,),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter project name',
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter project description',
                    ),
                  ),
                  SizedBox(height: 30,),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addProject,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, 
                      backgroundColor: BTNBlue,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text('Add Project'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
