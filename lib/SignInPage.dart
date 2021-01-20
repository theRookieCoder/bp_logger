import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;

import 'DriveAbstraction.dart'; // For signing in to Google

class SignInPage extends StatelessWidget {
  const SignInPage({Key key, @required this.onSignIn}) : super(key: key);
  final void Function(signIn.GoogleSignInAccount) onSignIn;

  Future<void> _signInWithGoogle() async {
    signIn.GoogleSignInAccount account;

    while (account == null) { // Have to sign in or app won't work
      account = await DriveAbstraction.signInWithGoogle(); // Sign in to Google
    }

    onSignIn(account);
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Sign in to use\nBP Logger",
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () async {await _signInWithGoogle();},
              child: Text("Sign in with Google"),
            ),
            Opacity(
              opacity: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Sign in to use\nBP Logger",
                  style: Theme.of(context).textTheme.headline3,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
