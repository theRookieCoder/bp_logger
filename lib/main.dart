import 'HomePage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignInAccount, GoogleSignIn;
import 'package:googleapis/drive/v3.dart' show DriveApi;
import 'DriveHelper.dart';

// Sign in with Google and then start the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool success = false;
  GoogleSignInAccount account;
  GoogleSignIn googleDriveSignIn;
  String error;

  for (int i = 0; i < 3 && success == false; i++) {
    print(i);
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
      error = e.toString();
    });
  }

  runApp(
    MyApp(
      account: account,
      googleSignIn: googleDriveSignIn,
      failed: !success,
      error: error,
    ),
  );
}

// Returns the HomePage if the sign in succeeded and an error page if the sign in failed
Widget screen(
  bool failed,
  GoogleSignInAccount account,
  GoogleSignIn googleSignIn,
  dynamic error,
) {
  if (failed) {
    return FailedPage(error: error.toString());
  } else {
    return HomePage(
      driveHelper: DriveHelper(account),
      onSignOut: () async {
        await googleSignIn
            .disconnect(); // Disconnect the user (signing out does not allow you to select a user)
      },
    );
  }
}

// The page that shows up if the sign in failed
class FailedPage extends StatelessWidget {
  const FailedPage({
    Key key,
    @required this.error,
  }) : super(key: key);
  final String error;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BP Logger"),
      ),
      body: Center(
        child: Text(
          "BP Logger tried to sign in and failed for more than 3 times\n" +
              "Error: $error",
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
    @required this.account,
    @required this.googleSignIn,
    @required this.failed,
    @required this.error,
  }) : super(key: key);
  final GoogleSignInAccount account;
  final GoogleSignIn googleSignIn;
  final bool failed;
  final String error;

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
      home: screen(
        failed,
        account,
        googleSignIn,
        error,
      ),
    );
  }
}
