import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_solution_challange/button.dart';
import 'package:google_solution_challange/input.dart';
import 'package:google_solution_challange/rules_page.dart';
import 'package:google_solution_challange/sign_in.dart';
import 'package:google_solution_challange/styled_text.dart';

class settingsPage extends StatefulWidget {
  const settingsPage({super.key});

  @override
  State<settingsPage> createState() => _settingsPageState();
}

class _settingsPageState extends State<settingsPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    DatabaseReference database = FirebaseDatabase.instance.ref();
    DatabaseReference userRef = database.child('user');
    DatabaseReference userId = userRef.child(currentUser!.uid);
    DatabaseReference credibility = userId.child('credibility');
    DatabaseReference locations = userId.child('locations');

      // int credibility_snapshot = credibility.get() as int
    
    String reward_text;



  // if (credibility >= 10) {
  //   return StyledText("Wow! you have 10 locations a day", 'bold', 10);
  // } else if (credibility >= 3) {
  //   return StyledText("Wait for your big prize", 'bold', 10);
  // } else {
  //   return StyledText("Be careful you Credibility\nis too low", 'bold', 10);
  // }

    void showRules() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Rules()));
    }

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
                                  SizedBox(
                                    height: 9,
                                  ),
                                  SvgPicture.asset(
                                    'assets/settings_page/credibility.svg',
                                    width: 30,
                                  ),
                                  Container(
                                    height: 30,
                                    child: StreamBuilder<String>(
                                      stream: credibility.onValue.map((event) =>
                                          event.snapshot.value.toString()),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }

                                        switch (snapshot.connectionState) {
                                          case ConnectionState.waiting:
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Container(
                                                height: 3,
                                                child: LinearProgressIndicator(
                                                  color: Color.fromARGB(
                                                      255, 137, 137, 137),
                                                ),
                                              ),
                                            );
                                          default:
                                            return Text(
                                              snapshot.data!,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                        }
                                      },
                                    ),
                                  ),
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
                                  SizedBox(
                                    height: 9,
                                  ),
                                  SvgPicture.asset(
                                    'assets/settings_page/reward.svg',
                                    width: 29,
                                  ),
                                  Container(
                                    height: 30,
                                    child:StyledText('Rewards', 'normal', 12),
                                    ),
                                  StyledText('Rewards', 'normal', 12),
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
                                  SizedBox(
                                    height: 9,
                                  ),
                                  SvgPicture.asset(
                                    'assets/settings_page/add_marker.svg',
                                    width: 30,
                                  ),
                                  Container(
                                    height: 30,
                                    child: StreamBuilder<String>(
                                      stream: locations.onValue.map((event) =>
                                          event.snapshot.value.toString()),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }

                                        switch (snapshot.connectionState) {
                                          case ConnectionState.waiting:
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Container(
                                                height: 3,
                                                child: LinearProgressIndicator(
                                                  color: Color.fromARGB(
                                                      255, 137, 137, 137),
                                                ),
                                              ),
                                            );
                                          default:
                                            return Text(
                                              snapshot
                                                  .data!, // Access the latest credibility value
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                        }
                                      },
                                    ),
                                  ),
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
