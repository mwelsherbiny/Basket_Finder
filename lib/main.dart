import 'package:flutter/material.dart';
import 'package:google_solution_challange/button.dart';
import 'package:google_solution_challange/styled_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 164),
                StyledText('Sign In', 'bold', 28),
                SizedBox(height: 94),
                Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: 30)),
                    SvgPicture.asset(
                      'assets/sign_up/email.svg',
                      semanticsLabel: 'Email Icon',
                      width: 18,
                      height: 18,
                    ),
                    StyledText('Email', 'normal', 12, textColor: const Color.fromRGBO(169, 169, 169, 1)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
