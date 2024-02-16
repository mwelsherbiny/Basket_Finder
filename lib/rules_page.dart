import 'package:easy_localization/easy_localization.dart';
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
          'rules'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          StyledText('rule1_head'.tr(), 'bold', 18),
          RuleDescription(
              'rule1'.tr()),
          SizedBox(
            height: 20,
          ),
          StyledText('rule2_head'.tr(), 'bold', 18),
          RuleDescription(
              'rule2_pt1'.tr()),
          SizedBox(height: 10,),
          RuleDescription(
              'rule2_pt2'.tr()),
          SizedBox(
            height: 20,
          ),
          StyledText('rule3_head'.tr(), 'bold', 18),
          RuleDescription(
              'rule3'.tr()),
          SizedBox(
            height: 20,
          ),
          StyledText('rule4_head'.tr(), 'bold', 18),
          RuleDescription(
              'rule4'.tr()),
          SizedBox(
            height: 20,
          ),
          StyledText('rule5_head'.tr(), 'bold', 18),
          RuleDescription(
              'rule5'.tr()),
          SizedBox(
            height: 20,
          ),
          StyledText('rule6_head'.tr(), 'bold', 18),
          RuleDescription(
              'rule6'.tr()),
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
