import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class AnimatedDialog extends StatefulWidget {
  const AnimatedDialog(
    this.dialog, {
    Key? key,
  }) : super(key: key);
  final Widget dialog;

  @override
  State<AnimatedDialog> createState() => _AnimatedDialogState();
}

class _AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  late final _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void initState() {
    super.initState();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) =>
      FadeScaleTransition(animation: _fadeController, child: widget.dialog);
}
