import 'package:flutter/material.dart';
import 'package:google_solution_challange/button.dart';
import 'package:google_solution_challange/sign_up.dart';
import 'package:google_solution_challange/social_sign_in.dart';
import 'package:google_solution_challange/styled_text.dart';
import 'package:google_solution_challange/input.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: ListView(
            padding: const EdgeInsets.all(25),
            children: [
              const SizedBox(height: 100),
              Center(child: StyledText('Sign In', 'bold', 28)),
              const SizedBox(height: 50),
              Input('Email', 'email.svg'),
              Input(
                'Password',
                'password.svg',
                hideText: true,
              ),
              Button('Sign In'),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 1,
                      color: const Color.fromRGBO(44, 44, 44, 1),
                    ),
                    StyledText(' Or ', 'normal', 16),
                    Container(
                      color: const Color.fromRGBO(44, 44, 44, 1),
                      width: 140,
                      height: 1,
                    )
                  ],
                ),
              ),
              SocialSignIn(),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StyledText('Don’t have an account?', 'normal', 12),
                  TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: StyledText('Create new one', 'normal', 12,
                          textColor: const Color.fromRGBO(55, 235, 115, 1)))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
