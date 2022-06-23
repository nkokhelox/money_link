import 'objectbox.g.dart'; // created by `flutter pub run build_runner build`

class ObjectBox {
  static late final Store _store;
  static Store get store => _store;

  static Future<Store> create() async {
    _store = await openStore();
    return store;
  }
}
