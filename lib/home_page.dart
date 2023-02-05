import "package:flutter/material.dart";
import "package:flutter/services.dart" show FilteringTextInputFormatter;
import "package:intl/intl.dart" show DateFormat;
import "package:flutter/gestures.dart" show TapGestureRecognizer;
import "package:url_launcher/url_launcher.dart" show LaunchMode, launchUrl;
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
  TextEditingController systolicTEC = TextEditingController(); // Systolic
  TextEditingController diastolicTEC = TextEditingController(); // Diastolic
  late DriveHelper driveHelper = widget.driveHelper; // "Backend" interface
  final formKey = GlobalKey<FormState>();

  double _getDrawerWidth() {
    double width = MediaQuery.of(context).size.width * 3 / 4;
    if (width > 280) {
      return 280;
    } else {
      return width;
    }
  }

  //Show a datepicker for selecting the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != date) {
      // Only update if user picked and isn't the same as before
      setState(() => date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BP Logger"),
        elevation: 5,
      ),
      drawer: SizedBox(
        width: _getDrawerWidth(),
        child: Drawer(
          child: Column(
            children: <Widget>[
              SizedBox(
                // Use drawer width to determine drawer header size
                height: _getDrawerWidth() * 1.1,
                child: DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Profile picture of user
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          height: _getDrawerWidth() / 2,
                          width: _getDrawerWidth() / 2,
                          child: driveHelper.avatar,
                        ),
                      ),
                      // Name of user
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          driveHelper.name ?? "",
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      // Email ID of user
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          driveHelper.email,
                          style: Theme.of(context).textTheme.titleMedium,
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
                onTap: () async => await launchUrl(
                  Uri.parse(
                      "https://docs.google.com/spreadsheets/d/${widget.logFileID}/"),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              // For opening the support page
              ListTile(
                leading: const Icon(Icons.contact_support_outlined),
                title: const Text("Get support"),
                onTap: () async => await launchUrl(
                  Uri.parse("https://therookiecoder.github.io/bp_logger"),
                  mode: LaunchMode.inAppWebView,
                ),
              ),
              // For showing information about the app e.g. version
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text("About"),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AboutDialog(
                        applicationName: "BP Logger",
                        applicationVersion: "Version ${widget.version}",
                        applicationIcon: Image.asset(
                          "assets/Icon_298x298.png",
                          scale: 4,
                        ),
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "This app is open source. Its code is available ",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                TextSpan(
                                  text: "on GitHub",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(
                                        color: Colors.blueAccent,
                                      ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async => await launchUrl(
                                          Uri.parse(
                                              "https://www.github.com/theRookieCoder/bp_logger"),
                                          mode: LaunchMode.externalApplication,
                                        ),
                                ),
                                TextSpan(
                                  text: " under the AGPL 3.0 License",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "\nFlutter and the related logo are trademarks of Google LLC. We are not endorsed by or affiliated with Google LLC",
                            style: Theme.of(context).textTheme.bodySmall,
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
                onTap: () => launchUrl(
                  Uri.parse("https://www.flutter.dev"),
                  mode: LaunchMode.externalApplication,
                ),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Invisible container to center the text
                    Container(width: 50),
                    // For displaying the date
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        DateFormat("d/M/y").format(date),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    // For changing the date
                    IconButton(
                      icon: const Icon(Icons.edit),
                      iconSize: 30.0,
                      tooltip: "Edit date",
                      onPressed: () async => await _selectDate(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 30.0,
                ),
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide()),
                    labelText: "Systolic",
                  ),
                  // Only digits, everything else gets rejected even if typed in
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number, // Number only keyboard
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 30.0,
                ),
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide()),
                    labelText: "Diastolic",
                  ),
                  // Only digits, everything else gets rejected even if typed in
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number, // Number only keyboard
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("ADD ENTRY"),
        onPressed: () async {
          // Don"t run if values are not correct
          if (formKey.currentState!.validate()) {
            // Get values from TextFieldControllers
            String systolic = systolicTEC.text;
            String diastolic = diastolicTEC.text;

            // Dismiss keyboard once button is pressed
            FocusManager.instance.primaryFocus?.unfocus();

            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return FileAppendDialog(
                  text:
                      "${DateFormat("d/M/y").format(date)}, ${DateFormat.Hm().format(DateTime.now())}, $systolic, $diastolic",
                  driveHelper: driveHelper,
                  logFileID: widget.logFileID,
                );
              },
              barrierDismissible: false,
            );

            systolicTEC.clear();
            diastolicTEC.clear();
          }
        },
      ),
    );
  }
}
