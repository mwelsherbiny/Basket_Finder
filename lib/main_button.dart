import 'package:flutter/material.dart';
import 'package:google_solution_challange/styled_text.dart';
import 'package:google_solution_challange/main_page.dart';

class MainButton extends StatelessWidget {
  String text;
  MainButton(this.text, this.applyFilter, {super.key});
  Function() applyFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 281,
      height: 49,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromRGBO(55, 235, 115, 1)),
      child: TextButton(
        onPressed: applyFilter,
        child: StyledText(text, 'bold', 16),
      ),
    );
  }
}
