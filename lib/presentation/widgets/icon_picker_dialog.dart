import 'package:flutter/material.dart';

class IconPickerDialog extends StatelessWidget {
  const IconPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // [수정] 데이터를 카테고리별 Map 형태로 변경
    final Map<String, List<String>> categorizedIcons = {
      '육류 / 계란': [
        '🥩', '🍗', '🍖', '🥓', '🥚', '🍳',
      ],
      '해산물': [
        '🐟', '🐠', '🐡', '🦐', '🦞', '🦀', '🦑', '🦪', '🍥',
      ],
      '과일': [
        '🍇', '🍈', '🍉', '🍊', '🍋', '🍌', '🍍', '🥭', '🍎', '🍏', 
        '🍐', '🍑', '🍒', '🍓', '🥝', '🍅', '🥥',
      ],
      '채소': [
        '🥑', '🍆', '🥔', '🍠', '🥕', '🌽', '🌶️', '🥒', '🥬', 
        '🥦', '🧄', '🧅', '🍄', '🥜', '🌰',
      ],
      '곡물 / 빵 / 면': [
        '🍞', '🥐', '🥖', '🥨', '🥯', '🥞', '🧇', '🍚', '🍙', 
        '🍘', '🍜', '🍝', '🥫',
      ],
      '조리된 음식 / 패스트푸드': [
        '🍔', '🍟', '🍕', '🌭', '🥪', '🌮', '🌯', '🫔', '🥗', 
        '🥘', '🍲', '🍛', '🍣', '🍱', '🥟', '🍤',
      ],
      '디저트 / 간식': [
        '🍦', '🍧', '🍨', '🍩', '🍪', '🎂', '🍰', '🧁', '🥧', '🍫', 
        '🍬', '🍭', '🍮', '🍯', '🍿', '🥠', '🥮', '🍢', '🍡',
      ],
      '음료 / 주류': [
        '🍼', '🥛', '☕️', '🍵', '🍶', '🍾', '🍷', '🍸', '🍹', 
        '🍺', '🍻', '🥂', '🥃', '🥤', '🧃', '🧉', '🧊',      ],
      '조미료 / 기타': [
        '🧂', '🧈', '🧀', '🏺',
      ],
    };

    return AlertDialog(
      title: const Text('아이콘 선택'),
      // [수정] 내용이 길어질 수 있으므로 SingleChildScrollView로 감싸줍니다.
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            // Map의 각 카테고리에 대해 위젯을 생성
            children: categorizedIcons.entries.map((entry) {
              final categoryTitle = entry.key;
              final icons = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 제목
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Text(
                      categoryTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // 아이콘 그리드
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: icons.length,
                    itemBuilder: (context, index) {
                      final icon = icons[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pop(icon);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}