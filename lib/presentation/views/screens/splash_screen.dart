import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/screen_size.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => StartState();
}

class StartState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return initScreen(context);
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() async {
    var duration = const Duration(milliseconds: 1500);
    return Timer(duration, route);
  }

  route() {
    Get.offNamed('/navi');
  }

  initScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/page1.png',
            ),
            Padding(
                padding: EdgeInsets.only(
              top: ScreenSize.sHeight * 20.0,
            )),
            Text(
              "우리집 냉장고 관리 V1.0",
              style: TextStyle(
                fontSize: ScreenSize.sWidth * 20.0,
                color: Colors.white,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: ScreenSize.sHeight * 20.0)),
            CircularProgressIndicator(
              backgroundColor: Colors.white,
              strokeWidth: ScreenSize.sWidth * 1,
            )
          ],
        ),
      ),
    );
  }
}
