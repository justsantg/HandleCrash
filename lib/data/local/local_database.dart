import 'package:hive/hive.dart';

class LocalDatabase {
  static const String boxName = 'handlecrashBox';

  Future<void> init() async {
    await Hive.openBox(boxName);
  }

  Box get box => Hive.box(boxName);

  dynamic getData(String key) {
    return box.get(key);
  }

  Future<void> saveData(String key, dynamic value) async {
    await box.put(key, value);
  }
}
