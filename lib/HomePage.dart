import 'dart:ui';

import 'package:bp_logger/FileLocationDialog.dart'; // Dialog for information about file location
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Duh
import 'package:flutter/services.dart'; // For rejecting everything but digits in the TextField
import 'package:intl/intl.dart'; // To get date and time
import 'DriveAbstraction.dart'; // Custom class for reading and writing to Google Drive
import 'package:googleapis/drive/v3.dart' as drive; // Google Drive API
import 'package:google_sign_in/google_sign_in.dart'
    as signIn; // For signing in to Google

class HomePage extends StatefulWidget {
  const HomePage(
      {Key key,
      @required this.account,
      @required this.onSignOut,
      @required this.googleDriveSignIn})
      : super(key: key);
  final signIn.GoogleSignInAccount account;
  final signIn.GoogleSignIn googleDriveSignIn;
  final void Function(
    signIn.GoogleSignInAccount,
    signIn.GoogleSignIn googleDriveSignIn,
    bool logOut,
  ) onSignOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String time = new DateFormat.Hm()
      .format(DateTime.now()); // Time is determined whenever app is launched
  drive.DriveApi driveApi; // For Google Drive API
  bool isLoading = false; // For making loading bar invisible when not used
  String loadingText = ""; // For showing the current state of the file write
  signIn.GoogleSignInAccount _account;
  String language = "English";
  List<String> languageList = [
    "English",
  ];

  double _getDrawerWidth(context) {
    double width = MediaQuery.of(context).size.width * 3 / 4;
    if (width > 300) {
      return 300;
    } else {
      return width;
    }
  }

  _instantiateApi() async {
    _account = widget.account;
    // Create an instance of the Drive API using Google account
    driveApi = await DriveAbstraction.createDriveApi(_account);
  }

  // Following runs when the program starts
  @override
  void initState() {
    super.initState();
    _instantiateApi(); // instantiate API asynchronous to main (in seperate thread)
  }

  static DateTime date =
      new DateTime.now(); // date variable gets changed by the DatePicker
  String dateString = new DateFormat("d/M/y")
      .format(date); // dateString gets updated every time date changes
  var textFieldController1 =
      TextEditingController(); // Control diastolic TextField
  var textFieldController2 =
      TextEditingController(); // Control systolic TextField

  // This snackbar pops up when the file has successfully been written to
  final snackBar = SnackBar(
    backgroundColor:
        Colors.grey[800], // Make it grey because it doesn't by default
    behavior: SnackBarBehavior
        .floating, // SnackBarBehavior.fixed looks horrible which is the default
    content: Text("Successfully wrote to log file",
        style: TextStyle(color: Colors.white)),
    duration: Duration(seconds: 2),
  );

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2015),
      lastDate: DateTime(3000),
    );
    if (picked != null && picked != date) {
      // Only update if user picked and isn't the same as before
      setState(() {
        date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          // PreferredSize is expected by bottom argument
          preferredSize: Size(double.infinity, 0.0),
          child: Opacity(
            opacity: isLoading ? 1.0 : 0.0, // Hide if false, show if true
            child: LinearProgressIndicator(),
          ),
        ),
        title: Text("BP Logger"),
        actions: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                onChanged: (newValue) {
                  setState(() {
                    language = newValue;
                  });
                },
                icon: Icon(Icons.language_outlined),
                value: language,
                items:
                    languageList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      drawer: Container(
        // 75% of the screen occupied by the drawer
        width: _getDrawerWidth(context),
        child: Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                height: 220.0,
                child: DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          _account.photoUrl,
                        ),
                      ),
                      Text(_account.displayName,
                          style: Theme.of(context).textTheme.headline4),
                      Text(_account.email,
                          style: Theme.of(context).textTheme.headline6)
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Log out"),
                onTap: () {
                  widget.onSignOut(
                    null,
                    widget.googleDriveSignIn,
                    true, // We want to log out the user so true
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text("Access file"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // custom builder for closing dialog
                      return FileLocationDialog();
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text("v0.8.4a (Logout update)"),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Invisible button of the same size to make the Text centered
                Opacity(
                  opacity: 0.0,
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    iconSize: 30.0,
                    onPressed: null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(dateString,
                      style:
                          Theme.of(context).textTheme.headline3), // Show date
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  iconSize: 30.0,
                  tooltip: "Edit date",
                  onPressed: () async {
                    await _selectDate(context);
                    dateString = DateFormat("d/M/y").format(
                        date); // Edit button beside date to change date (defaults to today)
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(time,
                  style: Theme.of(context).textTheme.headline3), // Show time
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
              child: TextField(
                maxLength: 3, // If your BP is more than 999, how are you alive?
                controller: textFieldController1,
                style: TextStyle(
                  fontSize: 25.0,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.lightBlue)),
                  labelText: 'Diastolic',
                ),
                // Allow strictly numbers only
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter
                      .digitsOnly, // Only digits, everything else gets rejected even if typed in
                ],
                keyboardType: TextInputType.numberWithOptions(
                    decimal: false, signed: false), // Number only keyboard
                onChanged: (text) {
                  setState(() {
                    time = new DateFormat.Hm().format(
                        DateTime.now()); // A hacky way to update the time
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
              child: TextField(
                maxLength: 3,
                controller: textFieldController2,
                style: TextStyle(
                  fontSize: 25.0,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(),
                  ),
                  labelText: 'Systolic',
                ),
                // Allow strictly numbers only
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter
                      .digitsOnly, // Only digits everything else is rejected even of typed in
                ],
                keyboardType: TextInputType.numberWithOptions(
                    decimal: false, signed: false), // Number only keyboard
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
          icon: Icon(Icons.storage),
          label: Text("ADD TO FILE"),
          onPressed: () async {
            // Get values from TextFieldControllers
            String diastolic = textFieldController1.text;
            String systolic = textFieldController2.text;

            // Dismiss keyboard once button is pressed
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }

            if (diastolic != "" && systolic != "") {
              // Don't run if values are not filled in
              setState(() {
                isLoading = true; // Start loading animation
                loadingText = "Getting file IDs";
              });

              await DriveAbstraction.init(
                  driveApi); // Checks if folder and file is there and also gets their IDs

              String text =
                  "$dateString, $time, $diastolic, $systolic"; // Text that has to be appended

              List<int> filteredDataStreamList =
                  []; // add()ing to a null var is a bad idea
              setState(() {
                loadingText = "Getting file data";
              });
              final dataStreamList = await DriveAbstraction.getFileData(
                  driveApi, DriveAbstraction.logFileID);

              setState(() {
                loadingText = "Filtering file data";
              });
              if (dataStreamList.length > 1) {
                for (var i in dataStreamList) {
                  for (var j in i) {
                    filteredDataStreamList.add(j);
                  }
                }
              } else {
                filteredDataStreamList = dataStreamList[0];
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
              ScaffoldMessenger.of(context).showSnackBar(
                  snackBar); // Show a snackbar to alert user that the write was successful
              // Clear the TextFields
              textFieldController1.clear();
              textFieldController2.clear();
            }
          },
        ),
      ),
    );
  }
}
