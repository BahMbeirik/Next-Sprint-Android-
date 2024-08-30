import 'package:flutter/material.dart';
import 'package:next_sprints/shared/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart'; // For json.encode

class Updatesprint extends StatefulWidget {
  final Map sprint;

  const Updatesprint({Key? key, required this.sprint}) : super(key: key);

  @override
  State<Updatesprint> createState() => _UpdatesprintState();
}

class _UpdatesprintState extends State<Updatesprint> {
  static const List<String> list = <String>['FINISHED', 'IN PROGRESS', 'TO DO'];
  late String dropdownValue;
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.sprint['catagory'] ?? list.first;
    _titleController = TextEditingController(text: widget.sprint['title'] ?? '');
    _bodyController = TextEditingController(text: widget.sprint['body'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarBlue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Update Sprint", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
        ],
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
                  SizedBox(height: 30),
                  Text("Update Sprint", style: TextStyle(fontSize: 20)),
                  SizedBox(height: 60),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter sprint title',
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _bodyController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter sprint body',
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      _updateSprint();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: BTNBlue,
                    ),
                    child: Text('Update'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateSprint() async {
  final int sprintId = widget.sprint['id'];
  final String url = 'http://192.168.1.155:8000/api/notes/$sprintId/';
  
  final response = await http.put(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await _getToken()}',
    },
    body: json.encode({
      'title': _titleController.text,
      'body': _bodyController.text,
      'catagory': dropdownValue,
      'project': widget.sprint['project'], // إضافة الحقل المطلوب
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sprint updated successfully!')),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update sprint: ${response.statusCode} ${response.body}')),
    );
    print('Failed to update sprint: ${response.statusCode} ${response.body}');
  }
}

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }
}
