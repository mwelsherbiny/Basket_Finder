import 'package:flutter/material.dart';
import 'package:google_solution_challange/main_page.dart';
import 'package:google_solution_challange/sign_in.dart';
import 'package:google_solution_challange/sign_up.dart';
import 'package:google_solution_challange/splash.dart';
import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool signedIn = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  var user =  FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('signed out');
      signedIn = false;
    } else {
      print('signed In');
      signedIn = true;
    }
  }); 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/':(context) => splash(),
        '/home':(context) => (signedIn)? MainPage() : SignIn(),
      },
      title: 'Google Solution Challenge',
      debugShowCheckedModeBanner: false,
      // home: (signedIn)? MainPage() : SignIn(),
    );
  }
}
