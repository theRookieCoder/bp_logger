import 'HomePage.dart';
import 'DriveHelper.dart';
import 'package:flutter/material.dart'; // UI
import 'package:google_fonts/google_fonts.dart'
    show GoogleFonts; // For monospaced font

Future<void> main() async {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  final driveHelper = DriveHelper();

  @override
  Widget build(BuildContext context) {
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
      home: FutureBuilder(
        future: driveHelper.signInAndInit(),
        builder: (context, snapshot) {
          Widget child;

          // If future resolved without any errors, show the homepage
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            child = HomePage(
              key: ValueKey(0),
              driveHelper: driveHelper,
            );
          }

          // If future resolved with an error, show a page with the error
          else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            child = Scaffold(
              key: ValueKey(1),
              backgroundColor: Colors.grey[850],
              body: Center(
                child: Column(
                  children: [
                    Text(
                      "BP Logger has encountered an error",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      "Error: ${snapshot.error}",
                      style: GoogleFonts.robotoMono(),
                    ),
                  ],
                ),
              ),
            );
          }

          // If future did not resolve yet, show progress indicator
          else {
            child = Scaffold(
              key: ValueKey(2),
              backgroundColor: Colors.grey[850],
              body: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(strokeWidth: 10),
                ),
              ),
            );
          }

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: child,
          );
        },
      ),
    );
  }
}
