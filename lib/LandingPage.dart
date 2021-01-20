import 'package:bp_logger/HomePage.dart';
import 'package:bp_logger/SignInPage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn; // For signing in to Google

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  signIn.GoogleSignInAccount _account;

  void _updateUser(signIn.GoogleSignInAccount account) {
    print("From LandingPage.dart: $account");
    setState(() {
      _account = account;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_account == null) {
      return SignInPage(
        onSignIn: _updateUser,
      ); // Sign in again of user is null
    } else {
      return HomePage(account: _account,);
    }
  }
}
