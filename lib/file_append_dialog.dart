import 'package:animated_check/animated_check.dart';
import 'package:drive_helper/drive_helper.dart';
import 'package:drive_helper/export_mime_types.dart';
import 'package:flutter/material.dart';

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
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late var future = widget.driveHelper.appendFile(
    widget.logFileID,
    widget.text,
    mime: SpreadsheetExportMIMETypes.csv,
  );

  AnimatedCheck showCheck() {
    _animationController.forward();
    return AnimatedCheck(
      progress: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCirc,
      )),
      color: Colors.green,
      size: 150,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: future,
        builder: (context, snapshot) => AlertDialog(
          title: Text(
            snapshot.connectionState == ConnectionState.done
                ? snapshot.hasError
                    ? "Error"
                    : "Success"
                : "Loading",
          ),
          content: Center(
            heightFactor: 1,
            child: SizedBox.square(
              dimension: 150,
              child: snapshot.connectionState == ConnectionState.done
                  ? snapshot.hasError
                      ? const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 130,
                        )
                      : showCheck()
                  : const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(strokeWidth: 5),
                    ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            snapshot.connectionState != ConnectionState.done
                ? OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("CANCEL"),
                    ))
                : FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("OK"),
                    )),
          ],
        ),
      );
}
