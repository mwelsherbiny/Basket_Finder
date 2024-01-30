import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_solution_challange/main.dart';
import 'package:google_solution_challange/sign_in.dart';
import 'package:google_solution_challange/input.dart';
import 'package:google_solution_challange/button.dart';
import 'package:google_solution_challange/styled_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_solution_challange/settings_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

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

    User? currentUser = FirebaseAuth.instance.currentUser;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              label: 'Add Location',
              icon: SvgPicture.asset('assets/main/add_location.svg'),
            ),
            BottomNavigationBarItem(
              label: 'Find Nearest',
              icon: SvgPicture.asset('assets/main/find_nearest.svg'),
            ),
            BottomNavigationBarItem(
              label: 'Settings',
              icon: SvgPicture.asset('assets/main/settings.svg'),
            ),
          ],
          onTap: (int index) {
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => settingsPage(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
