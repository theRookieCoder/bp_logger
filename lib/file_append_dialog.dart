import 'package:drive_helper/drive_helper.dart';
import 'package:flutter/material.dart';
import 'package:animated_check/animated_check.dart';

class FileAppendDialog extends StatefulWidget {
  const FileAppendDialog({
    Key? key,
    required this.text,
    required this.driveHelper,
    required this.logFileID,
  }) : super(key: key);
  final String text;
  final DriveHelper driveHelper;
  final String logFileID;

  @override
  FileAppendDialogState createState() => FileAppendDialogState();
}

class FileAppendDialogState extends State<FileAppendDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String title = "";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCirc,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: FutureBuilder(
        future: widget.driveHelper.appendFile(
          widget.logFileID,
          widget.text,
          mime: ExportMimeTypes.csv,
        ),
        builder: (context, snapshot) {
          // If future completed and has no errors
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            title = "Success";
            _animationController.forward();

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                AnimatedCheck(
                  progress: _animation,
                  color: Colors.green,
                  size: 100,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Text("OK"),
                  ),
                ),
              ],
            );
          }

          // If future completed and has errors
          else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            title = "Write failed";

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.close,
                    size: 100,
                    color: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Text("OK"),
                  ),
                ),
              ],
            );
          }

          // If future did not complete yet
          else {
            title = "Writing to file";
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                const SizedBox(
                  height: 150,
                  width: 150,
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
