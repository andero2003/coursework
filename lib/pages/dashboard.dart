import 'package:cwflutter/pages/authWebViewPage.dart';
import 'package:cwflutter/pages/newProjectPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  final String username;
  final String avatarUrl;
  final int userId;

  DashboardPage({required this.username, required this.avatarUrl, required this.userId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {   
    void _initProjectSetup() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NewProjectPage(userId: widget.userId)
        )
      );
    }
    List<Widget> _widgetOptions = <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.avatarUrl),
                    backgroundColor: Colors.grey.shade300,
                    radius: 40,
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Welcome, ${widget.username}!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Divider(
                thickness: 1.5,
              ),
              /*
              Text("Current Project", style:TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Image(
                    height: 56,
                    image: NetworkImage('https://tr.rbxcdn.com/d74dabd69b700545ad692135943d3794/150/150/Image/Png'),
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Balloon Simulator',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 5),

              Divider(
                thickness: 1.5,
              ),
              */
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.count(
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            crossAxisCount: 1,
            childAspectRatio: 1.5,
            children: [
              ElevatedButton(
                onPressed: _initProjectSetup, 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_outlined, size: 100,),
                    Text("Setup New Project", style: TextStyle(fontSize: 24),)
                  ],
                )
              )
            ],
          ),
        )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        }, 
        currentIndex: _selectedIndex,
        items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Projects',
            ),         
        ]
      ),
    );
  }
}
