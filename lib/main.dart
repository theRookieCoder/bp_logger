import 'package:bp_logger/LandingPage.dart';
import 'package:flutter/material.dart'; // Duh
import 'package:flutter/services.dart'; // For device orientation

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // Manually set via Xcode for iOS
    return MaterialApp(
      title: 'BP Logger',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        accentColor: Colors.blueAccent,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blueAccent,
        fontFamily: 'Roboto',
      ),
      home: LandingPage(),
    );
  }
}
