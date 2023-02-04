import 'package:drive_helper/drive_helper.dart';
import 'package:drive_helper/export_mime_types.dart';
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
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final _animation = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCirc),
  );
  late var future = widget.driveHelper.appendFile(
    widget.logFileID,
    widget.text,
    mime: SpreadsheetExportMIMETypes.csv,
  );

  AnimatedCheck showCheck(double size) {
    _animationController.forward();
    return AnimatedCheck(
      progress: _animation,
      color: Colors.green,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
            dimension: 100,
            child: snapshot.connectionState == ConnectionState.done
                ? snapshot.hasError
                    ? const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 100,
                      )
                    : showCheck(100)
                : const CircularProgressIndicator(),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          snapshot.connectionState == ConnectionState.done
              ? ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("OK"),
                  ))
              : Container(),
        ],
      ),
    );
  }
}
