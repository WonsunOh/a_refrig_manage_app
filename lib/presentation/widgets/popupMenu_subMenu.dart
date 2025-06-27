import 'package:flutter/material.dart';

import '../../common/utils/screen_size.dart';

class PopMenuSubMenu {
  static PopupMenuItem subMenu(String title, IconData icon, String itemValue) {
    return PopupMenuItem(
      value: itemValue,
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: ScreenSize.sWidth * 5),
          Text(title),
        ],
      ),
    );
  }
}
