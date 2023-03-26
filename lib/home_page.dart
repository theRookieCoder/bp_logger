import 'package:drive_helper/drive_helper.dart';
import "package:flutter/material.dart";
import "package:flutter/services.dart" show FilteringTextInputFormatter;
import "package:intl/intl.dart" show DateFormat;
import "package:package_info_plus/package_info_plus.dart";
import "package:url_launcher/url_launcher.dart" show LaunchMode, launchUrl;

import 'about_dialog.dart';
import 'animated_dialog_wrapper.dart';
import 'file_append_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.driveHelper,
    required this.logFileID,
    required this.packageInfo,
    required this.logOut,
  }) : super(key: key);
  final DriveHelper driveHelper;
  final String logFileID;
  final PackageInfo packageInfo;
  final VoidCallback logOut;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  var date = DateTime.now();
  final formKey = GlobalKey<FormState>();
  final systolicTEC = TextEditingController();
  final diastolicTEC = TextEditingController();

  double _getDrawerWidth() {
    double width = MediaQuery.of(context).size.width * 3 / 4;
    if (width > 280) {
      return 280;
    } else {
      return width;
    }
  }

  // Show a datepicker for selecting the date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );

    // Only update if user picked and isn't the same as before
    if (picked != null && picked != date) {
      setState(() => date = picked);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("BP Logger")),
        drawer: SizedBox(
          width: _getDrawerWidth(),
          child: Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: _getDrawerWidth(),
                    child: DrawerHeader(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox.square(
                            dimension: _getDrawerWidth() / 2,
                            child: widget.driveHelper.avatar,
                          ),
                          Container(height: 10),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.driveHelper.name ?? "",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.driveHelper.email,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Log out"),
                    onTap: () async {
                      await widget.driveHelper.signOut();
                      widget.logOut();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text("Access file"),
                    onTap: () async => await launchUrl(
                      Uri.parse(
                          "https://docs.google.com/spreadsheets/d/${widget.logFileID}"),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text("Get support"),
                    onTap: () async => await launchUrl(
                      Uri.parse("https://therookiecoder.github.io/bp_logger"),
                      mode: LaunchMode.inAppWebView,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text("About ${widget.packageInfo.appName}"),
                    onTap: () async => await showDialog(
                      context: context,
                      builder: (BuildContext context) => AnimatedDialog(
                        CustomAboutDialog(
                          widget.packageInfo,
                          image:
                              Image.asset("assets/Icon_298x298.png", scale: 4),
                          legalese:
                              "Flutter and the related logo are trademarks of Google LLC."
                              "We are not endorsed by or affiliated with Google LLC",
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  ListTile(
                    leading: const FlutterLogo(),
                    title: const Text("Built with the Flutter™ SDK"),
                    onTap: () async => await launchUrl(
                      Uri.parse("https://flutter.dev"),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      if (value != null && value.isNotEmpty) {
                        final val = int.parse(value);
                        if (val > 200) {
                          return "Too high";
                        } else if (val < 100) {
                          return "Too low";
                        } else {
                          return null;
                        }
                      } else {
                        return "Enter a value";
                      }
                    },
                    controller: systolicTEC,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
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
                      if (value != null && value.isNotEmpty) {
                        final val = int.parse(value);
                        if (val > 120) {
                          return "Too high";
                        } else if (val < 60) {
                          return "Too low";
                        } else {
                          return null;
                        }
                      } else {
                        return "Enter a value";
                      }
                    },
                    controller: diastolicTEC,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
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
            if (formKey.currentState!.validate()) {
              // Dismiss keyboard
              FocusManager.instance.primaryFocus?.unfocus();

              await showDialog(
                context: context,
                builder: (BuildContext context) =>
                    AnimatedDialog(FileAppendDialog(
                  text:
                      "${DateFormat("d/M/y").format(date)}, ${DateFormat.Hm().format(DateTime.now())}, ${systolicTEC.text}, ${diastolicTEC.text}",
                  driveHelper: widget.driveHelper,
                  logFileID: widget.logFileID,
                )),
                barrierDismissible: false,
              );

              systolicTEC.clear();
              diastolicTEC.clear();
            }
          },
        ),
      );
}
