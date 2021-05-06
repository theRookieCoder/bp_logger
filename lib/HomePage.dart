import "package:flutter/material.dart"; // UI
// For rejecting everything but digits in the TextField
import "package:flutter/services.dart"
    show FilteringTextInputFormatter;
import "package:intl/intl.dart" show DateFormat; // To get date and time
import "DriveHelper.dart"; // Backend stuff
import "package:flutter/gestures.dart" show TapGestureRecognizer; // For links
import "package:url_launcher/url_launcher.dart"
    show launch; // For opening links
import 'FileAppendDialog.dart';
import 'LogOutDialog.dart'; // For logging out

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
  static DateTime date = new DateTime.now();
  var textFieldController1 = TextEditingController(); // Diastolic
  var textFieldController2 = TextEditingController(); // Systolic
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

  // Runs when the program starts
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
      setState(() => date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BP Logger")),
      drawer: Container(
        width: _getDrawerWidth(context),
        child: Drawer(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                // Use drawer width to determine drawer header size
                height: _getDrawerWidth(context) * 0.8,
                child: DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Profile picture of user
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          height: _getDrawerWidth(context) / 2.5,
                          width: _getDrawerWidth(context) / 2.5,
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
              // For logging out
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
              // For showing the log file
              ListTile(
                leading: Icon(Icons.insert_drive_file_outlined),
                title: Text("Access file"),
                onTap: driveHelper.showLogFile,
              ),
              // For opening the support page
              ListTile(
                leading: Icon(Icons.contact_support_outlined),
                title: Text("Get support"),
                onTap: () =>
                    launch("https://therookiecoder.github.io/bp_logger"),
              ),
              // For showing information about the app e.g. version
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
                // For displaying the date
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    DateFormat("d/M/y").format(date),
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
                // For changing the date
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
            // For entering the diastolic value
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
                  border: new OutlineInputBorder(borderSide: new BorderSide()),
                  labelText: "Diastolic",
                ),
                // Only digits, everything else gets rejected even if typed in
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number, // Number only keyboard
              ),
            ),
            // For entering the systolic value
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
                  border: new OutlineInputBorder(borderSide: new BorderSide()),
                  labelText: "Systolic",
                ),
                // Only digits everything else is rejected even of typed in
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

            // Don"t run if values are not filled in
            if (diastolic != "" && systolic != "") {
              // Dismiss keyboard once button is pressed
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }

              String text =
                  "${DateFormat("d/M/y").format(date)}, ${DateFormat.Hm().format(DateTime.now())}, $diastolic, $systolic"; // Text that has to be appended

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FileAppendDialog(
                    text: text,
                    driveHelper: driveHelper,
                  );
                },
                barrierDismissible: false,
              );

              textFieldController1.clear();
              textFieldController2.clear();
            }
          },
        ),
      ),
    );
  }
}
