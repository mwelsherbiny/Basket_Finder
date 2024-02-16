import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_solution_challange/styled_text.dart';
import 'package:google_solution_challange/main_page.dart';
import 'package:google_solution_challange/input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class Button extends StatelessWidget {
  String text;
  Button(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    DatabaseReference database = FirebaseDatabase.instance.ref();
    DatabaseReference userRef = database.child('user');
    void displayError(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 8),
        ),
      );
    }

    void signIn() async {
      String email = Input.emailController.text;
      String password = Input.passwordController.text;
      print(email);
      print(password);
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'channel-error':
            displayError('Please enter email and password');
            break;
          case 'invalid-credential':
            displayError('Wrong password provided for that user');
            break;
          case 'invalid-email':
            displayError('Invalid email address');
            break;
          default:
            displayError(e.code);
            break;
        }
      }
    }

    void signUp() async {
      String email = Input.emailController.text;
      String password = Input.passwordController.text;
      String name = Input.usernameController.text;
      String confirmPassword = Input.confirmPasswordController.text;
      try {
        if (name.isEmpty) {
          displayError('Please enter your username');
          throw FormatException();
        }
        else if (password != confirmPassword)
        {
          displayError('Please make sure that passwords match');
          throw FormatException();
        }
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = credential.user;
        await user?.updateDisplayName(name);
        await user?.reload();
        String? uid = user?.uid;

        Map<dynamic, dynamic> userEntry = 
        {
          'name': name,
          'credibility': 3,
          'locations': 5,
          'last_updated': DateFormat('yMd').format(DateTime.now())
        };
        await userRef.child(uid!).set(userEntry);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'channel-error':
            displayError('Please enter email and password');
            break;
          case 'invalid-email':
            displayError('Invalid email address');
            break;
          case 'email-already-in-use':
            displayError('Email already in use, please sign in');
            break;
          default:
            print(e.message!);
            displayError(e.message!);
            break;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 281,
      height: 49,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromRGBO(55, 235, 115, 1)),
      child: TextButton(
        onPressed: (text == 'sign_in'.tr()) ? signIn : signUp,
        child: StyledText(text, 'bold', 16),
      ),
    );
  }
}
