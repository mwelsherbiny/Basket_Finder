import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_solution_challange/main.dart';
import 'package:google_solution_challange/main_page.dart';
import 'package:google_solution_challange/onboard_content.dart';
import 'package:google_solution_challange/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class onboard extends StatefulWidget {
  const onboard({super.key});

  @override
  State<onboard> createState() => _onboardState();
}

class _onboardState extends State<onboard> {
  int currIndex = 0;
  late PageController _controller;
  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }
  _storeonboardinfo() async{
    int isviewd = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isviewd);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  setState(() {
                    currIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Spacer(),
                        Image.asset(
                          contents[i].image,
                          width: 240,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          contents[i].title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          contents[i].discription,
                          textAlign: TextAlign.center,
                        ),
                        Spacer(),
                      ],
                    ),
                  );
                }),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  contents.length, (index) => buildcontainer(index)),
            ),
          ),
          Container(
            margin: EdgeInsets.all(40),
            child: SizedBox(
              height: 60,
              width: 200,
              child: ElevatedButton(
                  onPressed: () {
                    _storeonboardinfo();
                    if (currIndex == contents.length - 1) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => (signedIn)? MainPage() : SignIn() ));
                    }
                    _controller.nextPage(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    elevation: 0.0,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    currIndex == contents.length - 1 ? "Get Started" : "Next",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  )),
            ),
          )
        ],
      ),
    );
  }

  Container buildcontainer(int index) {
    return Container(
      height: 8,
      width: 8,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currIndex == index ? Colors.green : Colors.grey,
      ),
    );
  }
}
