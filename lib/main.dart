import 'package:flutter/material.dart'; // Duh
import 'package:intl/intl.dart'; // To get date and time
import 'package:path_provider/path_provider.dart'; // For iOS external storage
import 'package:ext_storage/ext_storage.dart'; // For Android external storage
import 'package:permission_handler/permission_handler.dart'; // Ask for storage permission
import 'dart:io'; // For actual file reading and writing

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BP Logger',
      theme: ThemeData(),
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
    await Permission.storage.request();// dummy code showing the wait period while getting the preferences
    setState(() {
      shouldProceed = true;//got the prefs; set to some value if needed
    });
  }

  @override
  void initState() {
    super.initState();
    _askPermission();//running initialisation code; getting prefs etc.
  }

  int diastolic;
  int systolic;
  String date = new DateFormat('d/M/y').format(DateTime.now());
  String time = new DateFormat('H:m').format(DateTime.now());
  var textFieldController1 = TextEditingController();
  var textFieldController2 = TextEditingController();

  Future<String> get _localPath async {
    String directoryPath;

    if (Platform.isAndroid) {
      directoryPath = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOCUMENTS);
    } else if (Platform.isIOS) {
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
                onChanged: (text) {
                  diastolic = int.parse(text);
                },
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
                onChanged: (text) {
                  systolic = int.parse(text);
                },
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
          if (diastolic != null || systolic != null) {
            final path = await _localPath;
            String row = "$date, $time, $diastolic, $systolic\n";
            print("Appending: $row");
            try {
              await writeRow(row);
            } on FileSystemException {
              print("Permission denied");
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
