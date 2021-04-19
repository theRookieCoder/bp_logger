import 'package:flutter/material.dart';

class LogOutDialog extends StatefulWidget {
  const LogOutDialog({
    Key key,
    @required this.logOut,
  }) : super(key: key);
  final Future<void> Function() logOut;

  @override
  _LogOutDialogState createState() => _LogOutDialogState();
}

class _LogOutDialogState extends State<LogOutDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Logout instructions",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline4.apply(fontSizeFactor: 0.9),
      ),
      content: Text(
        "To logout, follow the steps below\n  1. Click the logout button below\n  2. Close the website/app in the task switcher\n  3. Open the app again and sign in",
        style: Theme.of(context).textTheme.subtitle1,
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Text(
              "CANCEL",
              style: Theme.of(context).textTheme.button,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: widget.logOut,
          child: Padding(
            padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Text(
              "LOG OUT",
              style: Theme.of(context).textTheme.button,
            ),
          ),
        ),
      ],
    );
  }
}
