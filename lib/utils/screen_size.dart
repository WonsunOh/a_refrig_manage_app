// ### 사이즈 1 대비 스크린 비율 ### //

import 'package:get/get.dart';

//
class ScreenSize {
  static double width = Get.width;
  static double height = Get.height;

  // Get.width 와 Get.mediaQuery.size.width 가 표시되는 사이즈가 다르다고 하는 경우가
  // 있는데 확인 해봐야 함. 어느 블로그에서 봤는데 GetMaterial을 사용하는 경우 두 개가
  // 같다고도 하는데 확실 치 않음.
  // static double width = Get.mediaQuery.size.width;
  // static double height = Get.mediaQuery.size.height;

  static double sWidth = width * 0.0026;
  static double sHeight = height * 0.0012;
}
