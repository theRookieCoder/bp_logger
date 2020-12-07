import 'package:flutter/material.dart';

class ErrorDialog extends StatefulWidget {
  @override
  _ErrorDialogState createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      title: Text(
        'Error',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("We could not write to the log file. " +
              "This is most likely due to the app not having storage permissions. " +
              "To fix this, search for BP Logger in settings and under storage permissions, select allow"
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
          )
        ],
      ),
    );
  }
}