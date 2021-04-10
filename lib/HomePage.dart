import 'package:flutter/material.dart'; // Duh
// For rejecting everything but digits in the TextField
import 'package:flutter/services.dart'
    show TextInputFormatter, FilteringTextInputFormatter;
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignIn, GoogleSignInAccount;
import 'package:intl/intl.dart' show DateFormat; // To get date and time
import 'DriveHelper.dart'; // Backend stuff

class HomePage extends StatefulWidget {
  const HomePage({
    Key key,
    @required this.driveHelper,
    @required this.onSignOut,
    @required this.googleDriveSignIn,
  }) : super(key: key);
  final DriveHelper driveHelper;
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
  bool isLoading = false; // For making loading bar invisible when not used
  DriveHelper driveHelper; // 'Backend' interface

  // To get 3/4ths of the screen to display the drawer to a specific width on all devices
  double _getDrawerWidth(context) {
    double width = MediaQuery.of(context).size.width * 3 / 4;
    if (width > 280) {
      return 280;
    } else {
      return width;
    }
  }

  // Snackbar for status of the file write
  SnackBar _correctColouredSnackBar({@required String text}) {
    return SnackBar(
      backgroundColor: Theme.of(context).cardColor,
      behavior: SnackBarBehavior.floating,
      content: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).brightness.index.isOdd
                ? Colors.black
                : Colors.white54),
      ),
      duration: Duration(seconds: 2),
    );
  }

  // Following runs when the program starts
  @override
  void initState() {
    super.initState();
    driveHelper = widget.driveHelper;
  }

  // Date variable gets changed by the DatePicker
  static DateTime date = new DateTime.now();
  var textFieldController1 =
      TextEditingController(); // Control diastolic TextField
  var textFieldController2 =
      TextEditingController(); // Control systolic TextField

  // Datepicker for electing the date
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
      ),
      drawer: Container(
        // make 75% of the screen occupied by the drawer
        width: _getDrawerWidth(context),
        child: Drawer(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                // Use drawer width to determine drawer header
                height: _getDrawerWidth(context) * 0.8,
                child: DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          height: _getDrawerWidth(context) / 2.5,
                          width: _getDrawerWidth(context) / 2.5,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).brightness.index.isEven
                                    ? Colors.black87
                                    : Colors.white,
                                width: 2.0),
                            shape: BoxShape.circle,
                          ),
                          child: driveHelper.getAvatar(),
                        ),
                      ),
                      // Name of user
                      Text(driveHelper.getDisplayName(),
                          style: Theme.of(context).textTheme.headline5),
                      // Email ID of user
                      Text(driveHelper.getEmail(),
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
                      return driveHelper.getFileLocationDialog();
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text("About"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AboutDialog(
                        applicationName: "BP Logger",
                        applicationVersion: "v1.0.0",
                        applicationLegalese:
                            "This app is open sourced in Github under the AGPL 3.0 License",
                      );
                    },
                  );
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
                  child: Text(DateFormat("d/M/y").format(date),
                      style:
                          Theme.of(context).textTheme.headline3), // Show date
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  iconSize: 30.0,
                  tooltip: "Edit date",
                  onPressed: () async {
                    await _selectDate(context);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
              child: TextField(
                  maxLength: 3,
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
                  keyboardType: TextInputType.number // Number only keyboard
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
                keyboardType: TextInputType.number, // Number only keyboard
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

            // Don't run if values are not filled in
            if (diastolic != "" && systolic != "") {
              bool success = true;

              setState(() {
                isLoading = true; // Start loading animation
              });

              String text =
                  "${DateFormat("d/M/y").format(date)}, ${DateFormat.Hm().format(DateTime.now())}, $diastolic, $systolic"; // Text that has to be appended

              await driveHelper
                  .appendToFile(
                driveHelper.logFileID,
                text,
              )
                  .catchError((e) {
                print(e);
                success = false;
              });

              setState(() {
                isLoading = false;
              });

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  _correctColouredSnackBar(text: "File write succeeded"),
                );
                textFieldController1.clear();
                textFieldController2.clear();
              } else {
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
