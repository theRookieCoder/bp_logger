import 'package:bp_logger/FileLocation.dart'; // Dialog for information about file location
import 'package:flutter/material.dart'; // Duh
import 'package:intl/intl.dart'; // To get date and time
import 'package:path_provider/path_provider.dart'; // To get external storage path
import 'package:permission_handler/permission_handler.dart'; // Ask for storage permission if denied
import 'dart:io'; // For actual file input/output support
import 'package:bp_logger/ErrorDialog.dart'; // For error dialog because alert dialogs are long and annoying in flutter

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

  _askPermission() async {
    await Permission.storage.request();// Wait for user to accept
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
      // For Android you have to use this specific directory to avoid permission errors
      final directory = await getExternalStorageDirectory();
      directoryPath = directory.path;
    } else if (Platform.isIOS) {
      // For iOS you can configure the app documents directory to be viewable by the user
      final directory = await getApplicationDocumentsDirectory();
      directoryPath = directory.path;
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
        actions: [
          IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FileLocation();
                  },
                );
              },
          )
        ],
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
                  fontSize: 25.0,
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
                  fontSize: 25.0,
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
