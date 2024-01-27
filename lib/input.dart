import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_solution_challange/styled_text.dart';

class Input extends StatelessWidget {
  Input(this.promptType, this.iconFile, {super.key});
  String promptType;
  String iconFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(padding: EdgeInsets.only(left: 30)),
            SvgPicture.asset(
              'assets/sign_up/${iconFile}',
              semanticsLabel: '${promptType} prompt',
              width: 22,
              height: 22,
            ),
            Padding(padding: EdgeInsets.only(right: 8)),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                margin: EdgeInsets.only(right: 20),
                child: const SizedBox(    
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a search term',
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
