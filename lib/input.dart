import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

class Input extends StatelessWidget {
  Input(this.promptType, this.iconFile, {this.hideText = false, super.key});
  String promptType;
  String iconFile;
  bool hideText;
  static TextEditingController emailController = new TextEditingController();
  static TextEditingController passwordController = new TextEditingController();
  static TextEditingController confirmPasswordController = new TextEditingController();
  static TextEditingController usernameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/sign_up/$iconFile',
              semanticsLabel: '$promptType prompt',
              width: 22,
              height: 22,
            ),
            const Padding(padding: EdgeInsets.only(right: 8)),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    obscureText: hideText,
                    controller: () {
                      switch(promptType)
                      {
                        case 'email':
                          return emailController;
                        case 'password':
                          return passwordController;
                        case 'username':
                          return usernameController;
                        case 'confirm_password':
                          return confirmPasswordController;
                      }
                    }(),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: promptType.tr(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
