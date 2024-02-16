import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_solution_challange/main_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class SocialSignIn extends StatelessWidget
{
  SocialSignIn({super.key});

  @override
  Widget build(BuildContext context)
  {
    DatabaseReference database = FirebaseDatabase.instance.ref();
    DatabaseReference userRef = database.child('user');
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

        String? uid = FirebaseAuth.instance.currentUser?.uid;
        print(uid);
        bool alreadyExists = false;
        try
        {
          final userSnapshot = await userRef.get();
          final users = userSnapshot.value as Map<dynamic, dynamic>;
          users.forEach((key, value) {
          if(key == uid)
          {
            alreadyExists = true;
            throw FormatException();
          }
          });
        }
        catch(e) {}
        if(!alreadyExists)
        {
          Map<dynamic, dynamic> userEntry = 
          {
            'name': currentUser?.displayName,
            'credibility': 3,
            'locations': 5,
            'last_updated': DateFormat('yMd').format(DateTime.now())
          };
          await userRef.child(uid!).set(userEntry);
        }
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