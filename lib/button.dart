import 'package:flutter/material.dart';

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
      return TextButton(
        onPressed: signIn,
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(44, 44, 44, 1)),
        ),
      );
    }
    return TextButton(
        onPressed: signUp,
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color.fromRGBO(44, 44, 44, 1)),
        ));
  }
}
