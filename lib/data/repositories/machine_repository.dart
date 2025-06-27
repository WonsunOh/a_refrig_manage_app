
import '../models/machine_name_model.dart';
import '../datasources/machine_name_db_helper.dart';

/// MachineName 데이터 소스를 관리하는 저장소 클래스
class MachineRepository {
  final MachineNameDBHelper _dbHelper;

  // 생성자를 통해 외부에서 DB Helper를 주입받을 수 있도록 설계 (테스트 용이)
  MachineRepository({MachineNameDBHelper? dbHelper})
      : _dbHelper = dbHelper ?? MachineNameDBHelper();

  Future<List<MachineName>> getMachineNames() => _dbHelper.getMachineName();

  Future<int> addMachineName(MachineName machineName) =>
      _dbHelper.insertMachine(machineName);

  Future<int> updateMachineName(MachineName machineName) =>
      _dbHelper.updateMachine(machineName);

  Future<int> deleteMachineName(int id) => _dbHelper.deleteMachine(id);
}