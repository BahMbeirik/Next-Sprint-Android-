import 'package:flutter/material.dart';
import 'package:next_sprints/pages/sprints.dart';  // تأكد من استيراد صفحة Sprints
import 'package:next_sprints/shared/colors.dart';

class DetailProject extends StatelessWidget {
  final Map project;

  const DetailProject({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarBlue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          project['name'] ?? 'Project Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                project['name'] ?? 'No Name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25),
              Text(
                project['description'] ?? 'No Description',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Sprints(project: project),
                    ),
                  );
                },
                child: Text('View the Sprints'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
