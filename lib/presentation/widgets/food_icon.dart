import 'package:flutter/material.dart';

// 아이콘 식별자(String)를 받아서
// 이미지 에셋인지, 이모지인지 판단하여 올바른 위젯을 보여주는 헬퍼 위젯입니다.
class FoodIcon extends StatelessWidget {
  final String? iconIdentifier;
  final double size;

  const FoodIcon({
    super.key,
    required this.iconIdentifier,
    this.size = 24, // 기본 크기 24
  });

  @override
  Widget build(BuildContext context) {
    // 식별자가 'asset:'으로 시작하면 이미지로 취급
    if (iconIdentifier != null && iconIdentifier!.startsWith('asset:')) {
      // 'asset:' 부분을 제외한 순수 경로만 잘라냄
      final path = iconIdentifier!.substring(6);
      return Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        // 이미지를 찾을 수 없을 경우를 대비한 에러 처리
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error_outline, size: size, color: Colors.red);
        },
      );
    }
    
    // 그 외의 경우는 이모지(Text)로 취급
    return Text(
      iconIdentifier ?? '❓', // 값이 없으면 물음표 아이콘 표시
      style: TextStyle(fontSize: size * 0.9), // 크기에 비례하여 폰트 크기 조절
    );
  }
}