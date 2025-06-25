
import '../../models/alam_model.dart';
import '../database/alam_db_helper.dart';

class AlarmRepository {
  final AlamDBHelper _dbHelper;

  AlarmRepository({AlamDBHelper? dbHelper}) : _dbHelper = dbHelper ?? AlamDBHelper();

  Future<int> insertAlarm(Alam alam) => _dbHelper.insertAlam(alam);
  Future<List<Alam>> getAlarms() => _dbHelper.getAlam();
  Future<int> deleteAlarm(int id) => _dbHelper.deleteAlam(id);
}