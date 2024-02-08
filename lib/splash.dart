import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class splash extends StatefulWidget {
  const splash({super.key});

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
void initState() {
  super.initState();

  startTimer();
}

startTimer() {
  var duration = Duration(seconds: 3);

  return Timer(duration, route);
}

route() {
  Navigator.pushReplacementNamed(context, "/home");
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: content(),
    );
  }

  Widget content(){
    return Center(
      child: Container(
        child: Lottie.asset('assets/Basket_Finder_animation.json',
        width: 200,
        ),
      ),
    );
  }
}