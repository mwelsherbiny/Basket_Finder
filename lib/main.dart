import 'package:flutter/material.dart';
import 'package:google_solution_challange/main_page.dart';
import 'package:google_solution_challange/onboard.dart';
import 'package:google_solution_challange/sign_in.dart';
import 'package:google_solution_challange/sign_up.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

bool signedIn = false;
int? isviewd;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isviewd = prefs.getInt('onBoard');
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('ar', 'EG')],
      path: 'assets/translations',
      fallbackLocale: Locale('en', 'US'),
      child: MyApp()
    ),
  );
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
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(fontFamily: "googlesans"),
      title: 'Basket Finder',
      debugShowCheckedModeBanner: false,
      home: (isviewd == 0)? ((signedIn)? MainPage() : SignIn()) : onboard(),
      // home: (isfi)? MainPage() : SignIn(),
    );
  }
}
