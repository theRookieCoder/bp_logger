import "package:flutter/material.dart";
import "package:flutter/services.dart" show FilteringTextInputFormatter;
import "package:intl/intl.dart" show DateFormat;
import "package:flutter/gestures.dart" show TapGestureRecognizer;
import "package:url_launcher/url_launcher.dart" show launch;
import 'package:drive_helper/drive_helper.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'FileAppendDialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.driveHelper,
    required this.logFileID,
    required this.version,
  }) : super(key: key);
  final DriveHelper driveHelper;
  final String logFileID;
  final String version;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static DateTime date = new DateTime.now();
  var textFieldController1 = TextEditingController(); // Diastolic
  var textFieldController2 = TextEditingController(); // Systolic
  late DriveHelper driveHelper; // "Backend" interface

  // Runs when the program starts
  @override
  void initState() {
    super.initState();
    driveHelper = widget.driveHelper;
  }

  // To get 3/4ths of the screen to display the drawer to a suitable width on all devices
  double _getDrawerWidth(context) {
    double width = MediaQuery.of(context).size.width * 3 / 4;
    if (width > 280) {
      return 280;
    } else {
      return width;
    }
  }

  // Datepicker for selecting the date
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now().subtract(Duration(days: 7)),
      lastDate: DateTime.now(),
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
                          child: driveHelper.avatar,
                        ),
                      ),
                      // Name of user
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          driveHelper.name ?? "",
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      // Email ID of user
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          driveHelper.email,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // For logging out
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Log out"),
                onTap: () async {
                  await driveHelper.signOut();
                  Phoenix.rebirth(context);
                },
              ),
              // For showing the log file
              ListTile(
                leading: Icon(Icons.insert_drive_file_outlined),
                title: Text("Access file"),
                onTap: () async => launch(
                  "https://docs.google.com/spreadsheets/d/${widget.logFileID}/",
                ),
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
                        applicationVersion: "Version ${widget.version}",
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
                                        .caption!
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
      floatingActionButton: FloatingActionButton.extended(
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

            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return FileAppendDialog(
                  text: text,
                  driveHelper: driveHelper,
                  logFileID: widget.logFileID,
                );
              },
              barrierDismissible: false,
            );

            textFieldController1.clear();
            textFieldController2.clear();
          }
        },
      ),
    );
  }
}
