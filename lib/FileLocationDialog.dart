import 'package:flutter/material.dart';

class FileLocationDialog extends StatefulWidget {
  @override
  _FileLocationDialogState createState() => _FileLocationDialogState();
}

class _FileLocationDialogState extends State<FileLocationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      /*
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      */
      title: Text(
        'File location',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline4,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "To access the file, open Google Drive. Go to My Drive, then the BP Logger folder. Then open the file called 'log' to see your data.\nMake sure you are signed into the same Google account in Drive that you used in BP Logger",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
            child: RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }
}
