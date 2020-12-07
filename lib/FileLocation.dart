import 'package:flutter/material.dart';

class FileLocation extends StatefulWidget {
  @override
  _FileLocationState createState() => _FileLocationState();
}

class _FileLocationState extends State<FileLocation> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      title: Text(
        'Log file location',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("For Android, your log file is located in\n/storage/emulated/0/Android/com.therookiecoder.bp_logger/log.csv\n" +
              "Use a file explorer app like Google Files from the Playstore.\n" +
              "\nFor iOS, go to the Files app, then go to Browse, On My iPhone/iPad, bp_logger, log.csv"
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