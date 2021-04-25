import 'LogOutDialog.dart'; // For logging out
import "package:flutter/material.dart"; // UI
// For rejecting everything but digits in the TextField
import "package:flutter/services.dart"
    show TextInputFormatter, FilteringTextInputFormatter;
import "package:intl/intl.dart" show DateFormat; // To get date and time
import "DriveHelper.dart"; // Backend stuff
import "package:flutter/gestures.dart" show TapGestureRecognizer; // For links
import "package:url_launcher/url_launcher.dart"
    show launch; // For opening links

class HomePage extends StatefulWidget {
  const HomePage({
    Key key,
    @required this.driveHelper,
    @required this.onSignOut,
  }) : super(key: key);
  final DriveHelper driveHelper;
  final Future<void> Function() onSignOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // For date to be changed by datepicker
  static DateTime date = new DateTime.now();
  // Control diastolic TextField
  var textFieldController1 = TextEditingController();
  // Control systolic TextField
  var textFieldController2 = TextEditingController();
  // For making loading bar invisible when not used
  bool isLoading = false;
  DriveHelper driveHelper; // "Backend" interface

  // To get 3/4ths of the screen to display the drawer to a suitable width on all devices
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

  // Datepicker for selecting the date
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2015),
      lastDate: DateTime(3000),
    );
    if (picked != null && picked != date) {
      // Only update if user picked and isn"t the same as before
      setState(() {
        date = picked;
      });
    }
  }

  // Function for loading the progress indicator
  Widget progressHide() {
    return isLoading ? LinearProgressIndicator() : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          // PreferredSize is expected by bottom argument
          preferredSize: Size(double.infinity, 0.0),
          child: progressHide(),
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
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(driveHelper.getDisplayName(),
                            style: Theme.of(context).textTheme.headline4),
                      ),
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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return LogOutDialog(logOut: widget.onSignOut);
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file_outlined),
                title: Text("Access file"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return driveHelper.getFileLocationDialog();
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_support_outlined),
                title: Text("Get support"),
                onTap: () {
                  launch(
                    "https://therookiecoder.github.io/bp_logger",
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
                        applicationVersion: "Version ${driveHelper.version}",
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "This app is open sourced ",
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  TextSpan(
                                    text: "in Github",
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .apply(
                                          color: Colors.blue,
                                        ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        launch(
                                          "https://www.github.com/theRookieCoder/bp_logger",
                                        );
                                      },
                                  ),
                                  TextSpan(
                                    text: " under the AGPL 3.0 License",
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                // Invisible container to center the text
                Container(width: 50),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    DateFormat("d/M/y").format(date),
                    style: Theme.of(context).textTheme.headline3,
                  ),
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
                    labelText: "Diastolic",
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
                  labelText: "Systolic",
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

            // Don"t run if values are not filled in
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
