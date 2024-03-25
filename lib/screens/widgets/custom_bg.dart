import 'package:flutter/material.dart';

class CustomBackgraoud extends StatelessWidget {
  const CustomBackgraoud(
      {this.child,
      this.gradientColors = const [
        Colors.deepPurple,
        Colors.deepPurpleAccent,
        Colors.greenAccent
      ],
      this.alingmentBegin = Alignment.topRight,
      this.alignmentEnd = Alignment.bottomLeft,
      super.key});
  final Widget? child;
  final List<Color> gradientColors;
  final Alignment alingmentBegin;
  final Alignment alignmentEnd;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: alingmentBegin,
          end: alignmentEnd,
        ),
      ),
      child: child,
    );
  }
}
