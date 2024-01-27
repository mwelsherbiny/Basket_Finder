import 'package:flutter/material.dart';
import 'package:google_solution_challange/styled_text.dart';

class Button extends StatelessWidget {
  String text;
  Button(this.text, {super.key});
  void signIn() {
    // TODO
  }

  void signUp() {
    // TODO
  }

  @override
  Widget build(BuildContext context) {
    if (text == 'Sign In') {
      return Container(
        margin: EdgeInsets.only(top: 8),
        width: 281,
        height: 49,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(55, 235, 115, 1)
        ),
        child: TextButton(
          onPressed: signIn,
          child: StyledText(text, 'bold', 16),
        ),
      );
    }
    return TextButton(
      onPressed: signUp,
      child: StyledText(text, 'bold', 16),
    );
  }
}
