import 'package:bp_logger/DriveHelper.dart';
import 'package:flutter/material.dart';
import 'package:animated_check/animated_check.dart';

class FileAppendDialog extends StatefulWidget {
  const FileAppendDialog({
    Key key,
    @required this.text,
    @required this.driveHelper,
  }) : super(key: key);

  final String text;
  final DriveHelper driveHelper;

  @override
  _FileAppendDialogState createState() => _FileAppendDialogState();
}

class _FileAppendDialogState extends State<FileAppendDialog>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  String title = "";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _animation = new Tween<double>(
      begin: 0,
      end: 1,
    ).animate(new CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCirc,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: FutureBuilder(
        future: widget.driveHelper.appendToFile(
          widget.driveHelper.logFileID,
          widget.text,
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
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
                Padding(
                  padding: const EdgeInsets.all(20.0),
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
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
                Container(
                  height: 150,
                  width: 150,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
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
