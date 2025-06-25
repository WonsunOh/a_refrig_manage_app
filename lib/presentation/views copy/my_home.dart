// ### futureBuilder 를 사용하여 첫 화면 구성 ###

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../providers/machine_providers.dart';

// StatelessWidget을 ConsumerWidget으로 변경
class MyHome extends ConsumerWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  // build 메소드에 WidgetRef ref 파라미터 추가
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel의 상태를 watch. 상태가 변경되면 MyHome 위젯이 자동으로 다시 빌드됨.
    final machineState = ref.watch(machineViewModelProvider);

    return SafeArea(
        // AsyncValue를 사용하여 로딩, 에러, 데이터 상태에 따라 다른 UI를 보여줌
        child: machineState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (machines) {
            if (machines.isEmpty) {
              return const Center(child: Text('냉장고를 추가해주세요.'));
            }
            return ListView.builder(
              itemCount: machines.length,
              itemBuilder: (context, index) {
                final machine = machines[index];
                return Card(
                  // 시각적 구분을 위해 Card 위젯으로 감싸는 것을 추천합니다.
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(machine.refrigIcon ?? '🧊'),
                    ),
                    title: Text(
                      machine.machineName!,
                      maxLines: 1, // 최대 한 줄만 표시
                      overflow: TextOverflow.ellipsis, // 넘어가는 부분은 ... 처리
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    // [기능 1] 탭했을 때 해당 냉장고 페이지로 이동
                    onTap: () {
                      // GetX의 라우팅 기능은 그대로 사용합니다.
                      // RefrigPage로 이동하면서 machine의 id와 이름을 전달합니다.
                      Get.toNamed(
                        '/RefrigPage',
                        arguments: {
                          'machineId': machine.id,
                          'machineName': machine.machineName,
                        },
                      );
                    },

                    // [기능 2] 길게 눌렀을 때 삭제 확인 다이얼로그 표시
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('삭제 확인'),
                          content: Text(
                            '\'${machine.machineName}\' 기기를 정말 삭제하시겠습니까?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                // ViewModel의 deleteMachineName 메소드를 호출합니다.
                                // UI에서는 상태 변경을 요청하기만 하면 됩니다.
                                // .notifier를 통해 ViewModel의 메소드에 접근합니다.
                                ref
                                    .read(machineViewModelProvider.notifier)
                                    .deleteMachineName(machine.id!);
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      );
  }
}
