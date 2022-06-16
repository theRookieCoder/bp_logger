import "package:flutter/material.dart";
import "package:flutter/services.dart" show FilteringTextInputFormatter;
import "package:intl/intl.dart" show DateFormat;
import "package:flutter/gestures.dart" show TapGestureRecognizer;
import "package:url_launcher/url_launcher.dart" show launchUrl;
import 'package:drive_helper/drive_helper.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'file_append_dialog.dart';

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
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  DateTime date = DateTime.now();
  TextEditingController diastolicTEC = TextEditingController(); // Diastolic
  TextEditingController systolicTEC = TextEditingController(); // Systolic
  late DriveHelper driveHelper; // "Backend" interface
  final formKey = GlobalKey<FormState>();

  // Runs when the program starts
  @override
  void initState() {
    super.initState();
    driveHelper = widget.driveHelper;
  }

  // To get 3/4ths of the screen to display the drawer to a suitable width on all devices
  double _getDrawerWidth() {
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
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
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
      appBar: AppBar(title: const Text("BP Logger")),
      drawer: SizedBox(
        width: _getDrawerWidth(),
        child: Drawer(
          child: Column(
            children: <Widget>[
              SizedBox(
                // Use drawer width to determine drawer header size
                height: _getDrawerWidth() * 0.9,
                child: DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Profile picture of user
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          height: _getDrawerWidth() / 2.5,
                          width: _getDrawerWidth() / 2.5,
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
                leading: const Icon(Icons.logout),
                title: const Text("Log out"),
                onTap: () async {
                  await driveHelper.signOut();
                  // ignore: use_build_context_synchronously
                  Phoenix.rebirth(context);
                },
              ),
              // For showing the log file
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: const Text("Access file"),
                onTap: () async => launchUrl(Uri.parse(
                  "https://docs.google.com/spreadsheets/d/${widget.logFileID}/",
                )),
              ),
              // For opening the support page
              ListTile(
                leading: const Icon(Icons.contact_support_outlined),
                title: const Text("Get support"),
                onTap: () => launchUrl(
                  Uri.parse("https://therookiecoder.github.io/bp_logger"),
                ),
              ),
              // For showing information about the app e.g. version
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text("About"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AboutDialog(
                        applicationName: "BP Logger",
                        applicationVersion: "Version ${widget.version}",
                        applicationIcon: Image.asset(
                          "assets/Icon_298x298.png",
                          scale: 5,
                        ),
                        children: <Widget>[
                          RichText(
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
                                      launchUrl(Uri.parse(
                                        "https://www.github.com/theRookieCoder/bp_logger",
                                      ));
                                    },
                                ),
                                TextSpan(
                                  text: " under the AGPL 3.0 License",
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "\n\nFlutter and the related logo are trademarks of Google LLC. We are not endorsed by or affiliated with Google LLC",
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const Spacer(),
              ListTile(
                leading: const FlutterLogo(size: 30),
                title: const Text("Made with the Flutter™ SDK"),
                onTap: () => launchUrl(Uri.parse("https://www.flutter.dev")),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Form(
          key: formKey,
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
                    icon: const Icon(Icons.edit),
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
                child: TextFormField(
                  validator: (value) {
                    late int val;
                    if (value != "" && value != null) {
                      val = int.parse(value);
                    } else {
                      return "Enter a value";
                    }
                    if (val > 120) {
                      return "Too high";
                    } else if (val < 60) {
                      return "Too low";
                    } else {
                      return null;
                    }
                  },
                  controller: diastolicTEC,
                  style: const TextStyle(
                    fontSize: 25.0,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                    labelText: "Diastolic",
                  ),
                  // Only digits, everything else gets rejected even if typed in
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number, // Number only keyboard
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
                child: TextFormField(
                  validator: (value) {
                    late int val;
                    if (value != "" && value != null) {
                      val = int.parse(value);
                    } else {
                      return "Enter a value";
                    }
                    if (val > 200) {
                      return "Too high";
                    } else if (val < 100) {
                      return "Too low";
                    } else {
                      return null;
                    }
                  },
                  controller: systolicTEC,
                  style: const TextStyle(
                    fontSize: 25.0,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.storage),
        label: const Text("ADD TO FILE"),
        onPressed: () async {
          // Don"t run if values are not correct
          if (formKey.currentState != null &&
              formKey.currentState!.validate()) {
            // Get values from TextFieldControllers
            String diastolic = diastolicTEC.text;
            String systolic = systolicTEC.text;
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

            diastolicTEC.clear();
            systolicTEC.clear();
          }
        },
      ),
    );
  }
}
