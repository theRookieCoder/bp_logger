import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis/drive/v3.dart' as drive;
import 'DriveAbstraction.dart'; // For signing in to Google

class SignInPage extends StatefulWidget {
  const SignInPage({Key key, @required this.onSignIn}) : super(key: key);
  final void Function(signIn.GoogleSignInAccount account,
      signIn.GoogleSignIn googleSignIn, bool logOut) onSignIn;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<void> _signInWithGoogle(BuildContext context) async {
    bool success = false;

    signIn.GoogleSignInAccount account;
    signIn.GoogleSignIn googleDriveSignIn;
    while (success == false) {
      googleDriveSignIn = signIn.GoogleSignIn.standard(scopes: [
        drive.DriveApi.DriveFileScope
      ]); // Sign in to Google with Google Drive access
      success = true;
      account = await DriveAbstraction.signInWithGoogle(googleDriveSignIn)
          .catchError((e) async {
        print("Sign in failed");
        print("Error dump:\n$e");
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error occured"),
                content: Text(
                  "We could not sign you in successfully :(\nPlease contact ileshkt@gmail.com for assistance\n\nDebug:\n$e",
                ),
                actionsPadding: EdgeInsets.all(10.0),
                actions: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text("TRY AGAIN"),
                    ),
                  ),
                ],
              );
            });
        account = null;
        success = false;
        return;
      });

      if (success) {
        break;
      } else {
        continue;
      }
    }

    widget.onSignIn(account, googleDriveSignIn, false);
  }

  @override
  void initState() {
    super.initState();
    // instantiate API asynchronous to main (in seperate thread)
    _signInWithGoogle(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign in"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Signing you in...",
              style: Theme.of(context).textTheme.headline3,
            ),
            Opacity(
              opacity: 0,
              child: ElevatedButton(
                onPressed: () {},
                child: Text("Sign in with Google"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
