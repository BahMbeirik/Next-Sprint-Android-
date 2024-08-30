import 'package:flutter/material.dart';
import 'package:next_sprints/pages/detailSprint.dart';
import 'package:next_sprints/pages/addsprint.dart';  // تأكد من استيراد صفحة Addsprint
import 'package:next_sprints/shared/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Sprints extends StatefulWidget {
  final Map project;

  const Sprints({super.key, required this.project});

  @override
  State<Sprints> createState() => _SprintsState();
}

class _SprintsState extends State<Sprints> {
  List sprints = [];
  String selectedCategory = 'ALL'; // Default to show all sprints

  @override
  void initState() {
    super.initState();
    fetchSprints();
  }

  Future<void> fetchSprints() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.155:8000/api/projects/${widget.project['id']}/notes/'),
      headers: {
        'Authorization': 'Bearer ${await _getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonResponse = json.decode(decodedResponse);

      setState(() {
        if (jsonResponse.containsKey('notes')) {
          sprints = jsonResponse['notes'] as List<dynamic>;
        } else {
          sprints = [];
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sprints')),
      );
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // Filter sprints based on selectedCategory
    final filteredSprints = selectedCategory == 'ALL'
        ? sprints
        : sprints.where((sprint) => sprint['catagory'] == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarBlue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Sprints for ${widget.project['name']}', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Sprints for ${widget.project['name']}", style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.add, color: Colors.blueAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Addsprint(projectId: widget.project['id']),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          // Add a dropdown or buttons to select the category
          DropdownButton<String>(
            value: selectedCategory,
            items: <String>['ALL', 'FINISHED', 'IN PROGRESS', 'TO DO'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue!;
              });
            },
          ),
          SizedBox(height: 10),
          Expanded(
            child: filteredSprints.isEmpty
                ? Center(child: Text("No Sprints available"))
                : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: filteredSprints.length,
                    itemBuilder: (context, index) {
                      final sprint = filteredSprints[index];
                      return SprintCard(sprint: sprint);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SprintCard extends StatelessWidget {
  final Map sprint;

  const SprintCard({Key? key, required this.sprint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String body = sprint['body'] ?? '';
    String shortBody = body.split(' ').take(10).join(' ') + ' ...';

    // Format created_at using intl
    String createdAt = sprint['created_at'] ?? '';
    DateTime? dateTime = DateTime.tryParse(createdAt);
    String formattedDate = dateTime != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(dateTime)
        : 'Invalid date';

    // Determine the icon based on the category
    IconData statusIcon;
    Color iconColor;

    if (sprint['catagory'] == 'FINISHED') {
      statusIcon = Icons.check_circle_outline;
      iconColor = Colors.green;
    } else if (sprint['catagory'] == 'IN PROGRESS') {
      statusIcon = Icons.loop;
      iconColor = Colors.blue;
    } else {
      statusIcon = Icons.error_outline;
      iconColor = Colors.purple;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sprint['title'] ?? 'No Sprint',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                FaIcon(
                FontAwesomeIcons.solidNoteSticky, // or FontAwesomeIcons.noteSticky for the outlined version
                color: iconColor, // Customize the color as needed
                size: 25.0, // Customize the size as needed
              ),
              ],
            ),
          
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detailsprint(sprint: sprint),
                ),
              );
            },
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate),
                SizedBox(height: 20),
                Text(shortBody),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(statusIcon, color: iconColor, size: 25.0),
                    SizedBox(width: 8.0),
                    Text(sprint['catagory']),
                  ],
                ),
              ],
            ),
          ),
            
        ],
      ),
    );
  }
}
