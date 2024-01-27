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
            StyledText(promptType, 'normal', 12,
                textColor: const Color.fromRGBO(169, 169, 169, 1)),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 4, bottom: 8),
          width: 350,
          height: 1,
          color: Color.fromRGBO(44, 44, 44, 1),
        ),
      ],
    );
  }
}
