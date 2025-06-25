import 'package:flutter/material.dart';

class ErrorInquiry extends StatelessWidget {
  const ErrorInquiry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오류 및 개선문의'),
      ),
      body: Container(
        child: Text('오류 문의하기/앱 기능 건의사항'),
      ),
    );
  }
}
