import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_solution_challange/button.dart';
import 'package:google_solution_challange/sign_in.dart';
import 'package:google_solution_challange/styled_text.dart';
import 'package:google_solution_challange/input.dart';
import 'package:google_solution_challange/social_sign_in.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(25),
          children: [
            const SizedBox(height: 100),
            Center(child: StyledText('sign_up'.tr(), 'bold', 28)),
            const SizedBox(height: 50),
            Input('username', 'username.svg'),
            Input('email', 'email.svg'),
            Input('password', 'password.svg', hideText: true),
            Input('confirm_password', 'confirm.svg', hideText: true),
            Button('sign_up'.tr()),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 1,
                      color: const Color.fromRGBO(44, 44, 44, 1),
                    ),
                    StyledText('or'.tr(), 'normal', 16),
                    Container(
                      color: const Color.fromRGBO(44, 44, 44, 1),
                      width: 140,
                      height: 1,
                    )
                  ],
                ),
              ),
            ),
            SocialSignIn(),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledText('have_account'.tr(), 'normal', 12),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignIn()));
                    },
                    child: StyledText('sign_in'.tr(), 'normal', 12,
                        textColor: const Color.fromRGBO(55, 235, 115, 1)))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
