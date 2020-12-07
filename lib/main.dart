import 'package:flutter/material.dart'; // Duh
import 'package:intl/intl.dart'; // To get date and time
import 'package:path_provider/path_provider.dart'; // For external storage
import 'package:permission_handler/permission_handler.dart'; // Ask for storage permission
import 'dart:io'; // For actual file reading and writing
import 'package:bp_logger/ErrorDialog.dart'; // For error dialog cause alert dialogs are long and annoying

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BP Logger',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      darkTheme: ThemeData.dark(),
      home: RouteSplash(title: 'BP Logger'),
    );
  }
}

class RouteSplash extends StatefulWidget {
  RouteSplash({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RouteSplashState createState() => _RouteSplashState();
}

class _RouteSplashState extends State<RouteSplash> {
  bool shouldProceed = false;

  _askPermission() async {
    await Permission.storage.request();// Wait for user to accept
    setState(() {
      shouldProceed = true;//got the prefs; set to some value if needed
    });
  }

  @override
  void initState() {
    super.initState();
    _askPermission();//running initialisation code; getting prefs etc.
  }

  String date = new DateFormat('d/M/y').format(DateTime.now());
  String time = new DateFormat('H:m').format(DateTime.now());
  var textFieldController1 = TextEditingController();
  var textFieldController2 = TextEditingController();

  Future<String> get _localPath async {
    String directoryPath;

    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      directoryPath = directory.path;
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      directoryPath = directory.path; // For iOS you can configure the documents directory to be viewable by the user
    }
    return directoryPath;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/log.csv');
  }

  Future<File> writeRow(String row) async {
    final file = await _localFile;

    // Write the file.
    return file.writeAsString(row, mode: FileMode.append);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(date, style: Theme.of(context).textTheme.headline3),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(time, style: Theme.of(context).textTheme.headline3),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextField(
                controller: textFieldController1,
                style: TextStyle(
                  fontSize: 30.0,
                ),
                decoration: InputDecoration(
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide()
                  ),
                  hintText: 'Diastolic'
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextField(
                controller: textFieldController2,
                style: TextStyle(
                  fontSize: 30.0,
                ),
                decoration: InputDecoration(
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide()
                  ),
                  hintText: 'Systolic'
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add_box_rounded),
        label: Text("ADD TO LOGS"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: () async {
          String diastolic = textFieldController1.text;
          String systolic = textFieldController2.text;

          if (diastolic != "" && systolic != "") {
            final path = await _localPath;
            String row = "$date, $time, $diastolic, $systolic\n";
            print("Appending: $row");
            try {
              await writeRow(row);
            } on FileSystemException {
              print("Permission denied");
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog();
                },
              );
              return;
            }
            textFieldController1.clear();
            textFieldController2.clear();
            print("Appended successfully to $path/log.csv");
          }
        },
      ),
    );
  }
}
