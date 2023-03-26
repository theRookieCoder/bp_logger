import 'dart:async';
import 'dart:ui';

import 'package:drive_helper/drive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:package_info_plus/package_info_plus.dart';

import 'home_page.dart';

void main() => runApp(Phoenix(child: const MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  LoginScreen createState() => LoginScreen();
}

class LoginScreen extends State<MyApp> {
  late DriveHelper driveHelper;
  late PackageInfo packageInfo;
  late String logFileID;
  late Widget child;
  late var future = () async {
    driveHelper = await DriveHelper.initialise([DriveScopes.app]);

    final appFolderID = await driveHelper
        .getFileID("BP Logger")
        .then((files) => files[0])
        .catchError((error) async => await driveHelper.createFile(
              "BP Logger",
              FileMIMETypes.folder,
            ));

    logFileID = await driveHelper
        .getFileID("log")
        .then((files) => files[0])
        .catchError((error) async => await driveHelper.createFile(
              "log.csv",
              FileMIMETypes.file,
              text: "Date, Time, Systolic, Diastolic",
              parents: [appFolderID],
            ));

    packageInfo = await PackageInfo.fromPlatform();
  }();

  double _getProgressIndicatorSize(BuildContext context) {
    double size = MediaQuery.of(context).size.width / 2;
    if (size > 200) {
      return 200;
    } else {
      return size;
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.light,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(elevation: 5),
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.dark,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(elevation: 5),
        ),
        home: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            // If future resolved without any errors, show the homepage
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError) {
              child = HomePage(
                driveHelper: driveHelper,
                logFileID: logFileID,
                packageInfo: packageInfo,
              );
            }

            // If future resolved with an error, show a page with the error
            else if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasError) {
              child = ErrorPage(snapshot.error);
            }

            // If future did not resolve yet, show a progress indicator
            else {
              child = Scaffold(
                // backgroundColor: Colors.grey[850],
                body: Center(
                  child: SizedBox(
                    width: _getProgressIndicatorSize(context),
                    height: _getProgressIndicatorSize(context),
                    child: const CircularProgressIndicator(strokeWidth: 10),
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

class ErrorPage extends StatefulWidget {
  const ErrorPage(
    this.error, {
    Key? key,
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
      (timer) {
        if (countdown != 0) {
          setState(() => countdown--);
        } else {
          timer.cancel();
          Phoenix.rebirth(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Column(
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
                    style: const TextStyle(fontFeatures: [
                      FontFeature.tabularFigures(),
                    ]),
                  ),
          ],
        ),
      );
}
