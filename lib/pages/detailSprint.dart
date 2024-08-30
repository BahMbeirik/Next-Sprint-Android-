import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:next_sprints/pages/updateSprint.dart';
import 'package:next_sprints/shared/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Detailsprint extends StatelessWidget {
  final Map sprint;

  const Detailsprint({Key? key, required this.sprint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format created_at using intl
    String createdAt = sprint['created_at'] ?? '';
    DateTime? dateTime = DateTime.tryParse(createdAt);
    String formattedDate = dateTime != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(dateTime)
        : 'Invalid date';

    // Format updated_at using intl
    String updatedAt = sprint['updated_at'] ?? '';
    DateTime? dateTimeU = DateTime.tryParse(updatedAt);
    String formattedDateU = dateTimeU != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(dateTimeU)
        : 'Invalid date';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarBlue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          sprint['title'] ?? 'Sprint Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
              border: Border(
                left: BorderSide(
                  color: BTNBlue,
                  width: 3,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(height: 20),
                    Text(
                      sprint['title'] ?? 'No Title',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    Text('Date Created: $formattedDate'),
                    Text('Date Updated: $formattedDateU'),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Updatesprint(sprint: sprint),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text('Are you sure you want to delete this sprint?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Delete'),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              ),
                            );
                            if (confirmDelete) {
                              await _deleteSprint(context);
                            }
                          },
                        ),
                      ],
                    ),
                    Text(sprint['body'] ?? 'No Body'),
                    SizedBox(height: 25),
                  ],
                ),
                SizedBox(height: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSprint(BuildContext context) async {
    final int sprintId = sprint['id']; // Ensure you have a valid ID
    final String url = 'http://192.168.1.155:8000/api/notes/$sprintId/';
    
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getToken()}',
      },
    );

    if (response.statusCode == 204) { // 204 No Content means success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sprint deleted successfully!')),
      );
      Navigator.pop(context); // Navigate back to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete sprint')),
      );
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }
}
