import 'package:drive_helper/drive_helper.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import 'dart:ui';

import 'home_page.dart';

void main() => runApp(Phoenix(child: const MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late DriveHelper driveHelper;
  late String logFileID;
  late String version;
  late var future = initialise();

  Future<void> initialise() async {
    driveHelper = await DriveHelper.initialise([DriveScopes.app]);

    final appFolderID = await driveHelper
        .getFileID("BP Logger")
        .then((files) => files[0])
        .catchError((error) async =>
            await driveHelper.createFile("BP Logger", FileMIMETypes.folder));

    logFileID = await driveHelper
        .getFileID("log")
        .then((files) => files[0])
        .catchError((error) async => await driveHelper.createFile(
              "log.csv",
              FileMIMETypes.file,
              text: "Date, Time, Systolic, Diastolic",
              parents: [appFolderID],
            ));

    version = (await PackageInfo.fromPlatform()).version;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          Widget child;

          // If future resolved without any errors, show the homepage
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            child = HomePage(
              driveHelper: driveHelper,
              logFileID: logFileID,
              version: version,
            );
          }

          // If future resolved with an error, show a page with the error
          else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            child = ErrorPage(error: snapshot.error);
          }

          // If future did not resolve yet, show a progress indicator
          else {
            child = Scaffold(
              backgroundColor: Colors.grey[850],
              body: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width / 2,
                  child: const CircularProgressIndicator(strokeWidth: 15),
                ),
              ),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
      ),
    );
  }
}

class ErrorPage extends StatefulWidget {
  const ErrorPage({
    Key? key,
    required this.error,
  }) : super(key: key);
  final dynamic error;

  @override
  ErrorPageState createState() => ErrorPageState();
}

class ErrorPageState extends State<ErrorPage> {
  var countdown = 5;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (providedTimer) {
        if (countdown != 0) {
          setState(() => countdown--);
        } else {
          providedTimer.cancel();
          Phoenix.rebirth(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Error"),
        elevation: 5,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "BP Logger encountered an error :(",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            Container(height: 20),
            Text(
              "Error: ${widget.error}",
              style: GoogleFonts.jetBrainsMono(),
            ),
            Container(height: 20),
            countdown == 0
                ? const Text("Restarting...")
                : Text(
                    "Restarting in $countdown seconds",
                    style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()]),
                  ),
          ],
        ),
      ),
    );
  }
}
