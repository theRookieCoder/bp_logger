import 'dart:async';

import 'package:animations/animations.dart';
import 'package:drive_helper/drive_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:package_info_plus/package_info_plus.dart';

import 'home_page.dart';

void main() => runApp(MaterialApp(
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
      home: const MyApp(),
    ));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  LoginScreen createState() => LoginScreen();
}

class LoginScreen extends State<MyApp> {
  late DriveHelper driveHelper;
  late PackageInfo packageInfo;
  late String logFileID;
  late var future = initialise();

  Future<void> initialise() async {
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
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: future,
        builder: (context, snapshot) => PageTransitionSwitcher(
          transitionBuilder: (
            Widget child,
            Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation,
          ) =>
              FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
          child: snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasError
              ? HomePage(
                  driveHelper: driveHelper,
                  logFileID: logFileID,
                  packageInfo: packageInfo,
                  logOut: () {
                    future = initialise();
                    setState(() {});
                  },
                )
              : Scaffold(
                  appBar: AppBar(
                      title: Text(
                    snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasError
                        ? "Error"
                        : "Signing in...",
                  )),
                  body: snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasError
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "BP Logger encountered an error :(",
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              Container(height: 50),
                              Text(
                                "Error: ${snapshot.error}",
                                style: GoogleFonts.jetBrainsMono(),
                              ),
                              Container(height: 50),
                              FilledButton(
                                onPressed: () {
                                  future = initialise();
                                  setState(() {});
                                },
                                child: const Text("TRY AGAIN"),
                              )
                            ],
                          ),
                        )
                      : Center(
                          child: SizedBox.square(
                          dimension: (MediaQuery.of(context).size.width / 2)
                              .clamp(0, 200),
                          child:
                              const CircularProgressIndicator(strokeWidth: 10),
                        )),
                ),
        ),
      );
}
