import 'HomePage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignInAccount, GoogleSignIn;
import 'package:googleapis/drive/v3.dart' show DriveApi;
import 'DriveHelper.dart';

Future<void> main() async {
  bool success = false;
  GoogleSignInAccount account;
  GoogleSignIn googleDriveSignIn;

  while (success == false) {
    googleDriveSignIn = GoogleSignIn.standard(scopes: [
      DriveApi.driveFileScope,
    ]); // Sign in to Google with Google Drive access
    success = true;
    account = await DriveHelper.signInWithGoogle(googleDriveSignIn)
        .catchError((e) async {
      print("Sign in failed");
      print("Error dump:\n$e");
      account = null;
      success = false;
    });

    if (success && account != null) {
      break;
    } else {
      continue;
    }
  }

  runApp(
    MyApp(
      account: account,
      googleSignIn: googleDriveSignIn,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
    @required this.account,
    @required this.googleSignIn,
  }) : super(key: key);
  final GoogleSignInAccount account;
  final GoogleSignIn googleSignIn;

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
      home: HomePage(
        driveHelper: DriveHelper(account),
        onSignOut: () async {
          await googleSignIn
              .disconnect(); // Disconnect the user (signing out does not allow you to select a user)
        },
      ),
    );
  }
}
