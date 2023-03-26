import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CustomAboutDialog extends StatefulWidget {
  const CustomAboutDialog(
    this.packageInfo, {
    Key? key,
    required this.image,
    required this.legalese,
  }) : super(key: key);
  final PackageInfo packageInfo;
  final String legalese;
  final Image image;

  @override
  State<CustomAboutDialog> createState() => _CustomAboutDialogState();
}

class _CustomAboutDialogState extends State<CustomAboutDialog> {
  @override
  Widget build(BuildContext context) => AlertDialog(
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: widget.image,
              ),
              Container(width: 30),
              Column(
                children: [
                  Text(
                    widget.packageInfo.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Container(height: 15),
                  Text(
                    "Version ${widget.packageInfo.version}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ),
          Container(height: 30),
          Text(widget.legalese),
        ]),
        actions: [
          TextButton(
            onPressed: () => showLicensePage(context: context),
            child: const Text("View Licenses"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      );
}
