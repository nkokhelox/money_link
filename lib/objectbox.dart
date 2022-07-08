import 'package:money_link/objectbox.g.dart';

class ObjectBox {
  static late final Store _store;
  static Store get store => _store;

  static Future<Store> create() async {
    _store = await openStore();
    return store;
  }
}
