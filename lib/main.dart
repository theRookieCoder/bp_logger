import 'package:bp_logger/FileLocationDialog.dart'; // Dialog for information about file location
import 'package:flutter/material.dart'; // Duh
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'; // For rejecting everything but digits in TextField
import 'package:intl/intl.dart'; // To get date and time
import 'DriveAbstraction.dart'; // Custom class for reading and writing to Google Drive
import 'package:googleapis/drive/v3.dart' as drive; // Google Drive API


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // Manually set via Xcode for iOS
    return MaterialApp(
      title: 'BP Logger',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        accentColor: Colors.blueAccent,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blueAccent,
        fontFamily: 'Roboto',
      ),
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
  String time = new DateFormat.Hm().format(DateTime.now()); // Time is determined whenever app is launched
  drive.DriveApi driveApi;
  bool isLoading = false;
  String loadingText = "";

  _instantiateApi() async {
    driveApi = await DriveAbstraction.createDriveApi();
  }

  @override
  void initState() {
    super.initState();
    _instantiateApi(); // Sign in to Google and create a Drive API instace
  }

  static DateTime date = new DateTime.now(); // date var gets changed by DatePicker
  String dateString = new DateFormat("d/M/y").format(date); // dateString gets updated every time date changes
  var textFieldController1 = TextEditingController(); // Control TextField diastolic
  var textFieldController2 = TextEditingController(); // Control TextField systolic

  // This snackbar pops up when the file has successfully been written to
  final snackBar = SnackBar(
    backgroundColor: Colors.grey[800],
    behavior: SnackBarBehavior.floating,
    content: Text("Successfully wrote to log file", style: TextStyle(color: Colors.white)),
    duration: Duration(seconds: 2),
  );

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2015),
      lastDate: DateTime(3000),
    );
    if (picked != null && picked != date) // Only update if user picked and isn't the same as before
      setState(() {
        date = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 0.0),
          child: Opacity(
            opacity: isLoading ? 1.0 : 0.0,
            child:  LinearProgressIndicator(),
          ),
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: "Location of log file",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) { // custom builder for closing dialog
                  return FileLocationDialog();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                // Invisible button of same size to make the Text centered
                Opacity(
                  opacity: 0.0,
                  child: IconButton( // onPressed removed to make this not pressable
                    icon: Icon(Icons.edit),
                    iconSize: 40.0,
                    onPressed: null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(dateString, style: Theme.of(context).textTheme.headline3), // Show date
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  iconSize: 40.0,
                  onPressed: () async {
                    await _selectDate(context);
                    dateString = DateFormat("d/M/y").format(date); // Edit button beside date to change date (default today)
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(time, style: Theme.of(context).textTheme.headline3), // Show time
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextField(
                maxLength: 3,
                controller: textFieldController1,
                style: TextStyle(
                  fontSize: 25.0,
                ),
                decoration: InputDecoration(
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.lightBlue)
                  ),
                  labelText: 'Diastolic'
                ),
                // Allow strictly numbers only
                inputFormatters: <TextInputFormatter> [
                  FilteringTextInputFormatter.digitsOnly, // Only digits everything else is rejected even if typed in
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false), // Number only keyboard
                onChanged: (text) {
                  setState(() {
                    time = new DateFormat.Hm().format(DateTime.now());
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextField(
                maxLength: 3,
                controller: textFieldController2,
                style: TextStyle(
                  fontSize: 25.0,
                ),
                decoration: InputDecoration(
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(),
                  ),
                  labelText: 'Systolic'
                ),
                // Allow strictly numbers only
                inputFormatters: <TextInputFormatter> [
                  FilteringTextInputFormatter.digitsOnly, // Only digits everything else is rejected even of typed in
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false), // Number only keyboard
                onChanged: (text) {
                  setState(() {
                    time = new DateFormat.Hm().format(DateTime.now());
                  });
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          icon: Icon(Icons.add_box_rounded),
          label: Text("ADD TO LOGS"),
          onPressed: () async {
            String diastolic = textFieldController1.text;
            String systolic = textFieldController2.text;

            // Dismiss keyboard
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }

            // if (diastolic != "" && systolic != "") {
              setState(() {
                isLoading = true;
                loadingText = "Getting file IDs";
              });

              await DriveAbstraction.init(driveApi);

              String text = "$dateString, $time, $diastolic, $systolic";

              List<int> filteredDataStreamList = [];
              setState(() {
                loadingText = "Getting file data";
              });
              final dataStreamList = await DriveAbstraction.getFileData(driveApi, DriveAbstraction.logFileID);

              setState(() {
                loadingText = "Filtering file data";
              });
              for (var i in dataStreamList) {
                for (var j in i) {
                  filteredDataStreamList.add(j);
                }
              }
              print(filteredDataStreamList);

              setState(() {
                loadingText = "Updating file";
              });
              await DriveAbstraction.appendToFile(
                driveApi,
                DriveAbstraction.logFileID,
                text,
                filteredDataStreamList,
              );

              setState(() {
                isLoading = false;
                loadingText = "";
              });
              Scaffold.of(context).showSnackBar(snackBar);
              textFieldController1.clear();
              textFieldController2.clear();
            // }
          },
        ),
      ),
    );
  }
}
