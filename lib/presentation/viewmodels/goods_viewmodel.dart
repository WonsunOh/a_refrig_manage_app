import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/goods_repository.dart';
import '../../data/models/product_model.dart';

class GoodsViewModel extends StateNotifier<AsyncValue<Map<String, Map<String, List<Product>>>>> {
  final GoodsRepository _repository;
  final String refrigName;

  GoodsViewModel(this._repository, this.refrigName)
      : super(const AsyncValue.loading()) {
    fetchGoods();
  }

  /// 음식 목록 불러오기
   Future<void> fetchGoods() async {
    state = const AsyncValue.loading();
    try {
      const defaultSections = ['냉장실', '냉동실', '실온'];
      final finalGroupedMap = <String, Map<String, List<Product>>>{
        for (var section in defaultSections) section: {'기본칸':[]},
      };
      
      final allGoods = await _repository.getGoods(refrigName);

      // 1. 1단계 그룹화: 보관 장소(storageName)로 그룹화
      final groupedByStorage = groupBy(allGoods, (product) => product.storageName ?? '기타');

      // 2. 2단계 그룹화: 각 보관 장소 그룹 내에서 컨테이너(containerName)로 다시 그룹화
      groupedByStorage.forEach((storageName, goodsList) {
        final groupedByContainer = groupBy(goodsList, (product) => product.containerName ?? '기본칸');
        finalGroupedMap[storageName] = groupedByContainer;
      });
      
      state = AsyncValue.data(finalGroupedMap);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // 음식을 다른 위치로 옮기는 메소드
  Future<bool> moveGood(Product product, String newRefrigName, String newStorageName, String newContainerName) async {
    try {
      final movedProduct = product.copyWith(
        refrigName: newRefrigName,
        storageName: newStorageName,
        containerName: newContainerName,
      );
      await _repository.updateGood(movedProduct);
      fetchGoods();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 음식 추가
  Future<void> addGood(Product product) async {
    await _repository.addGood(product);
    fetchGoods(); // 목록 갱신
  }

  /// 음식 수정
  Future<void> updateGood(Product product) async {
    await _repository.updateGood(product);
    fetchGoods(); // 목록 갱신
  }

  /// 음식 삭제
  Future<void> deleteGood(int id) async {
    await _repository.deleteGood(id);
    fetchGoods(); // 목록 갱신
  }
}