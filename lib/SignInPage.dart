import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;

import 'DriveAbstraction.dart'; // For signing in to Google

class SignInPage extends StatefulWidget {
  const SignInPage({Key key, @required this.onSignIn}) : super(key: key);
  final void Function(signIn.GoogleSignInAccount) onSignIn;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<void> _signInWithGoogle(BuildContext context) async {
    bool success = false;

    signIn.GoogleSignInAccount account;
    while (success == false) {
      success = true;
      account = await DriveAbstraction.signInWithGoogle().catchError((e) async {
        print("Sign in failed");
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error occured"),
                content: Text(
                  "We could not sign you in to Google successfully :(\nPlease contact ileshkt@gmail.com for assistance\n\nDebug:\n$e",
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

    widget.onSignIn(account);
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
