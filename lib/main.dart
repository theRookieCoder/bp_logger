import 'package:drive_helper/drive_helper.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';

import 'home_page.dart';

void main() => runApp(Phoenix(child: MyApp()));

// ignore: use_key_in_widget_constructors
class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final driveHelper = DriveHelper();
  late String logFileID;
  late String version;

  Future<void> initialise() async {
    late String appFolderID;

    await driveHelper.signInAndInit([DriveScopes.app]);

    await driveHelper.getFileID("BP Logger").then(
      (files) {
        appFolderID = files[0];
      },
    ).catchError(
      (error) async {
        appFolderID = await driveHelper.createFile(
          "BP Logger",
          FileMimeTypes.folder,
        );
      },
    );
    await driveHelper.getFileID("log").then(
      (files) {
        logFileID = files[0];
      },
    ).catchError(
      (error) async {
        logFileID = await driveHelper.createFile(
          "log.csv",
          FileMimeTypes.file,
          text: "Date, Time, Diastolic, Systolic",
          parents: [appFolderID],
        );
      },
    );

    await PackageInfo.fromPlatform().then((info) => version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.indigo,
        ),
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.indigo,
        ),
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      home: FutureBuilder(
        future: initialise(),
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

          // If future did not resolve yet, show progress indicator
          else {
            child = Scaffold(
              backgroundColor: Colors.grey[850],
              body: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  height: MediaQuery.of(context).size.width / 1.5,
                  child: const CircularProgressIndicator(strokeWidth: 10),
                ),
              ),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
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
  int countdown = 10;
  late final Timer timer;

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "BP Logger encountered an error",
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              "Error: ${widget.error}",
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoMono(),
            ),
            Text("Restarting in $countdown seconds"),
          ],
        ),
      ),
    );
  }
}
