import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: promptType,
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
