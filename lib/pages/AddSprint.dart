import 'package:flutter/material.dart';
import 'package:next_sprints/shared/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Addsprint extends StatefulWidget {
  final int projectId;

  const Addsprint({super.key, required this.projectId});

  @override
  State<Addsprint> createState() => _AddsprintState();
}

class _AddsprintState extends State<Addsprint> {
  static const List<String> list = <String>['FINISHED', 'IN PROGRESS', 'TO DO'];
  String dropdownValue = list.first;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarBlue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Add Sprint", style: TextStyle(color: Colors.white)),
        
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              width: 350,
              height: 550,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: BTNBlue, width: 3),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 30),
                  Text("Add new Sprint", style: TextStyle(fontSize: 20)),
                  SizedBox(height: 60),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter sprint title',
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: bodyController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter sprint body',
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status : '),
                      DropdownButton<String>(
                        value: dropdownValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                            print('Selected category: $dropdownValue');
                          });
                        },
                        items: list.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _addSprint,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: BTNBlue,
                    ),
                    child: Text('Add Sprint'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addSprint() async {
  final String title = titleController.text;
  final String body = bodyController.text;
  final String category = dropdownValue;


  if (title.isNotEmpty && body.isNotEmpty) {
    final url = 'http://192.168.1.155:8000/api/notes/';
    final token = await _getToken();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'body': body,
        'catagory': category,
        'project': widget.projectId
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sprint added successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add sprint')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all fields')),
    );
  }
}

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  
}
