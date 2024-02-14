import 'package:flutter/material.dart';

class StyledText extends StatelessWidget {
  StyledText(this.text, this.weight, this.size,
      {super.key, this.textColor = const Color.fromRGBO(44, 44, 44, 1)});
  String text;
  String weight;
  double size;
  Color textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:  TextStyle(
        fontSize: size,
        fontWeight: (weight == 'normal') ? FontWeight.w400 : FontWeight.w700,
        color: textColor,
      ),
    );
  }
}
