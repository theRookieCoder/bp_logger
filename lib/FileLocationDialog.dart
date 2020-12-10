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
        'Log file location',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline4,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("For Android, your log file is located in\n/storage/emulated/0/Android/data/com.therookiecoder.bp_logger/files/log.csv\n" +
              "Use a file explorer app like Google Files from the Playstore.\n" +
              "\nFor iOS, go to the Files app, then go to Browse, On My iPhone/iPad, bp_logger, log.csv",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(fontSize: 18),
            ),
          )
        ],
      ),
    );
  }
}