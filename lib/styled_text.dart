import 'package:flutter/material.dart';

class StyledText extends StatelessWidget {
  StyledText(this.text, {super.key});
  String text;

  @override
  Widget build(BuildContext context) {
    return Text(
          text,
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(44, 44, 44, 1)),
        );
  }
}
