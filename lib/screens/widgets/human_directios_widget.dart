import 'package:flutter/material.dart';

class HumanStepsWidget extends StatefulWidget {
  const HumanStepsWidget({required this.stringHumanDirections,super.key});
  final String stringHumanDirections;
  @override
  State<HumanStepsWidget> createState() => _HumanStepsWidgetState();
}

class _HumanStepsWidgetState extends State<HumanStepsWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: 390,
      child: Column(
        children: [
          const Text('Human Directions'),
          SizedBox(
            height: 300,
            width: 390,
            child: SingleChildScrollView(
              child: Text(
                (widget.stringHumanDirections),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
