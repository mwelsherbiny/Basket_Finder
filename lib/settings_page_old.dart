import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_solution_challange/button.dart';
import 'package:google_solution_challange/input.dart';
import 'package:google_solution_challange/rules_page.dart';
import 'package:google_solution_challange/sign_in.dart';
import 'package:google_solution_challange/styled_text.dart';

DatabaseReference database = FirebaseDatabase.instance.ref();
DatabaseReference userRef = database.child('user');

class settingsPage extends StatelessWidget {
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Constructor
  settingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    void showRules() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Rules()));
    }
    String realtime_credibility = '0';
    String realtime_rewards = '0';
    String realtime_locations = '0';
    userRef.onValue.listen(
      (event) {
        
      } 
      );

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
              centerTitle: true,
              backgroundColor: Colors.white,
              title: Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: StyledText('Dash Board', 'bold', 30)),
                  // User Info Widget-----------------------------------------
                  SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      height: 95,
                      width: 400,
                      color: Color.fromARGB(255, 222, 222, 222),
                      child: Row(
                        children: [
                          Container(
                            color: Color.fromARGB(255, 222, 222, 222),
                            width: 99,
                            child: Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 9,),
                                     SvgPicture.asset(
                                      'assets/settings_page/credibility.svg',
                                      width: 30,
                                    ),
                                    StyledText(realtime_credibility, 'normal', 20),
                                    StyledText('My credibility', 'normal', 12)
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.white,
                          ),
                          Container(
                            color: Color.fromARGB(255, 222, 222, 222),
                            width: 99,
                            child: Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 9,),
                                     SvgPicture.asset(
                                      'assets/settings_page/reward.svg',
                                      width: 29,
                                    ),
                                    StyledText(realtime_credibility, 'normal', 20),
                                    StyledText('Rewards', 'normal', 12)
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(
                            color: Colors.white,
                          ),
                          Container(
                            color: Color.fromARGB(255, 222, 222, 222),
                            width: 99,
                            child: Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 9,),
                                     SvgPicture.asset(
                                      'assets/settings_page/add_marker.svg',
                                      width: 30,
                                    ),
                                    StyledText(realtime_credibility, 'normal', 20),
                                    StyledText('Locations', 'normal', 12)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ----------------------------------------------------------------
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(height: 25),
                  StyledText('Username', 'bold', 20),
                  StyledText(currentUser!.displayName!, 'normal', 16),
                  SizedBox(
                    height: 20,
                  ),
                  StyledText('Email', 'bold', 20),
                  StyledText(currentUser!.email!, 'normal', 16),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(0),
                    ),
                    onPressed: showRules,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText('Platform Rules', 'bold', 20),
                        StyledText('Help keep the app accurate', 'normal', 16),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(0),
                      ),
                      onPressed: signOut,
                      child: StyledText('Sign Out', 'bold', 20)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
