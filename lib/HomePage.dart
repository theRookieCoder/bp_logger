import 'package:bp_logger/FileLocationDialog.dart'; // Dialog for information about file location
import 'package:flutter/material.dart'; // Duh
import 'package:flutter/services.dart'
    show
        TextInputFormatter,
        FilteringTextInputFormatter; // For rejecting everything but digits in the TextField
import 'package:intl/intl.dart' show DateFormat; // To get date and time
import 'DriveAbstraction.dart'; // Custom class for reading and writing to Google Drive
import 'package:googleapis/drive/v3.dart' show DriveApi; // Google Drive API
import 'package:google_sign_in/google_sign_in.dart'
    show
        GoogleSignIn,
        GoogleSignInAccount,
        GoogleUserCircleAvatar; // For signing in to Google

class HomePage extends StatefulWidget {
  const HomePage(
      {Key key,
      @required this.account,
      @required this.onSignOut,
      @required this.googleDriveSignIn})
      : super(key: key);
  final GoogleSignInAccount account;
  final GoogleSignIn googleDriveSignIn;
  final Future<void> Function(
    GoogleSignInAccount,
    GoogleSignIn googleDriveSignIn,
    bool logOut,
  ) onSignOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String time = new DateFormat.Hm()
      .format(DateTime.now()); // Time is determined whenever app is launched
  DriveApi driveApi; // For Google Drive API
  bool isLoading = false; // For making loading bar invisible when not used
  String loadingText = ""; // For showing the current state of the file write
  GoogleSignInAccount _account;
  String language = "English";
  List<String> languageList = [
    "English",
  ];
  bool verboseMode = false;

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

  SnackBar _correctColouredSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Theme.of(context).cardColor,
      behavior: SnackBarBehavior.floating,
      content: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).brightness.index.isOdd
                ? Colors.black
                : Colors.white),
      ),
      duration: Duration(seconds: 2),
    );
  }

  // Following runs when the program starts
  @override
  void initState() {
    super.initState();
    _instantiateApi();
  }

  static DateTime date =
      new DateTime.now(); // date variable gets changed by the DatePicker
  String dateString = new DateFormat("d/M/y")
      .format(date); // dateString gets updated every time date changes
  var textFieldController1 =
      TextEditingController(); // Control diastolic TextField
  var textFieldController2 =
      TextEditingController(); // Control systolic TextField

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
        // make 75% of the screen occupied by the drawer
        width: _getDrawerWidth(context),
        child: Drawer(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                height: _getDrawerWidth(context) * 0.8,
                child: DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: _getDrawerWidth(context) / 2.5,
                        width: _getDrawerWidth(context) / 2.5,
                        child: GoogleUserCircleAvatar(identity: _account),
                      ),
                      // Name of user
                      Text(_account.displayName,
                          style: Theme.of(context).textTheme.headline4),
                      // Email ID of user
                      Text(_account.email,
                          style: Theme.of(context).textTheme.headline6)
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Log out"),
                onTap: () async {
                  await widget.onSignOut(
                    null, // Nullify account to go to signInPage
                    widget
                        .googleDriveSignIn, // Required to sign out from Google
                    true, // We want to log out the user so make this true
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text("Access file"),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // Custom builder for closing dialog
                      return FileLocationDialog(
                        driveApi: driveApi,
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text("About"),
                hoverColor: Theme.of(context).disabledColor.withAlpha(0x00),
                enableFeedback: false,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AboutDialog(
                        applicationName: "BP Logger",
                        applicationVersion: "v0.10.1",
                        applicationLegalese:
                            "This app is open sourced in Github under the AGPL 3.0 License",
                      );
                    },
                  );
                },
                onLongPress: () {
                  if (verboseMode) {
                    verboseMode = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      _correctColouredSnackBar(text: "Verbose mode turned off"),
                    );
                  } else {
                    verboseMode = true;
                    ScaffoldMessenger.of(context).showSnackBar(
                      _correctColouredSnackBar(text: "Verbose mode turned on"),
                    );
                  }
                },
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
              bool success = true;

              // Don't run if values are not filled in
              setState(() {
                isLoading = true; // Start loading animation
                loadingText = "Getting file IDs";
              });

              await DriveAbstraction.init(driveApi);

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
                  filteredDataStreamList.addAll(i);
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
              ).catchError((e) {
                print(e);
                success = false;
              });

              if (success) {
                setState(() {
                  isLoading = false;
                  loadingText = "";
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  _correctColouredSnackBar(text: "File write succeeded"),
                );

                textFieldController1.clear();
                textFieldController2.clear();
              } else {
                setState(() {
                  isLoading = false;
                  loadingText = "";
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  _correctColouredSnackBar(
                      text: "File write failed, please try again"),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
