import 'package:flutter/material.dart';

class DialogHandler {
  Future<void> showMyDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission denied'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You have denied access to external storage.'),
                Text('BP Logger requires external storage permissions for storing BP data.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ask again'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}