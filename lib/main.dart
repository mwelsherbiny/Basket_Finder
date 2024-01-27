import 'package:flutter/material.dart';
import 'package:google_solution_challange/button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home : Scaffold(
        backgroundColor: Colors.white,
        body: Container(
           child: Center(
             child: Column(
                children: [
                  SizedBox(height: 164),
                  Button('Sign Up'),
                ],
             ),
           ),
        ),
      ),
    );
  }
}
