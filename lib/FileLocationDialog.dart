import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:url_launcher/url_launcher.dart' show launch;

class FileLocationDialog extends StatefulWidget {
  const FileLocationDialog({Key key, @required this.fileID}) : super(key: key);
  final String fileID;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'To view the file, tap ',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                TextSpan(
                  text: 'here',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.15,
                    color: Colors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch(
                        "https://docs.google.com/spreadsheets/d/${widget.fileID}/",
                      );
                    },
                ),
              ],
            ),
          ),
          Text(""),
          Text(
            "To access the file itself:\n- Open Google Drive\n- Go to My Drive\n- Go to a folder called 'BP Logger'\n- Open the file called 'log' to see your data.\nMake sure you are signed into the same Google account in Drive that you used in BP Logger",
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
