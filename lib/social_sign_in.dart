import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_solution_challange/main_page.dart';

class SocialSignIn extends StatelessWidget
{
  const SocialSignIn({super.key});

  @override
  Widget build(BuildContext context)
  {
    void signInWithGoogle() async {
      try
      {
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        // Obtain the auth details from the request
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithCredential(credential);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
      }
      catch(e)
      {}
    }
    return Center(
        child: GestureDetector(
          onTap: () => signInWithGoogle(),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(204, 255, 221, 1),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1, color: Color.fromRGBO(44, 44, 44, 1)),
            ),
            width: 64,
            height: 64,
            child: Center(
              child: SvgPicture.asset(
                'assets/sign_up/google.svg',
                width: 48,
                height: 48,
              ),
            ),
          ),
        ),
    );
  }
}