import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_solution_challange/styled_text.dart';

class Rules extends StatelessWidget {
  Rules({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Rules',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          StyledText('Contribution Limits', 'bold', 18),
          RuleDescription(
              '\u2022You can only add up to 5 new bin locations per day. This ensures high quality contributions.'),
          SizedBox(
            height: 20,
          ),
          StyledText('Location Accuracy', 'bold', 18),
          RuleDescription(
              '\u2022Only add bins you can currently see in person. Do not speculate on distant/unknown locations.'),
          SizedBox(height: 10,),
          RuleDescription(
              '\u2022Make sure to provide an accurate address or directions. Locations must be verifiable.'),
          SizedBox(
            height: 20,
          ),
          StyledText('Location Reporting', 'bold', 18),
          RuleDescription(
              '\u2022Help the community by reporting on locations added by others. Your reports determine validity.'),
          SizedBox(
            height: 20,
          ),
          StyledText('Invalid Location Detection', 'bold', 18),
          RuleDescription(
              '\u2022If a location receives 3 "not found" reports, it will be removed from the map.'),
          SizedBox(
            height: 20,
          ),
          StyledText('User Credibility', 'bold', 18),
          RuleDescription(
              '\u2022The user who added an invalidated location loses credibility, except if it previously had 3 "found" reports indicating it was legitimate at some point.'),
          SizedBox(
            height: 20,
          ),
          StyledText('Report Proximity', 'bold', 18),
          RuleDescription(
              '\u2022You can only submit location reports for bins near your current reported location for accuracy.'),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class RuleDescription extends StatelessWidget {
  RuleDescription(String this.description, {super.key});
  String description;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(178, 190, 181, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: StyledText(description, 'normal', 16),
    );
  }
}
