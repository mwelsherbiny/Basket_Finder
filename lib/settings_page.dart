import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_solution_challange/input.dart';
import 'package:google_solution_challange/sign_in.dart';
import 'package:google_solution_challange/styled_text.dart';

class settingsPage extends StatelessWidget
{
  User? currentUser = FirebaseAuth.instance.currentUser;

  settingsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    void signOut() async {
      Input.passwordController.text = '';
      Input.confirmPasswordController.text = '';
      Input.usernameController.text = '';
      Input.emailController.text = '';
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          children: [
            AppBar(
              title: Text('Settings'),
            ),
            SizedBox(height: 25),
            Center(child: StyledText('${currentUser?.displayName}', 'bold', 28)),
            SizedBox(height: 50,),
            TextButton(onPressed: signOut, child: StyledText('Sign Out', 'bold', 16)),
          ],
        ),
      ),
    );
  }
}