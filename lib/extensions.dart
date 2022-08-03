import 'package:intl/intl.dart';

extension NiceDateTime on DateTime {
  static const _second_value = 1000;
  static const _minute_value = 60 * _second_value;
  static const _hour_value = 60 * _minute_value;
  static const _day_value = 24 * _hour_value;
  static const _week_value = 7 * _day_value;

  String niceDescription({String suffix = ""}) {
    final int millisAgo =
        DateTime.now().millisecondsSinceEpoch - millisecondsSinceEpoch;
    if (millisAgo < 0) {
      return "Future";
    } else if (millisAgo < _second_value) {
      return "${millisAgo}ms$suffix";
    } else if (millisAgo < _minute_value) {
      return "${millisAgo ~/ _second_value}s$suffix";
    } else if (millisAgo < _hour_value) {
      return "${millisAgo ~/ _minute_value}m$suffix";
    } else if (millisAgo < _day_value) {
      return "${millisAgo ~/ _hour_value}h$suffix";
    } else if (millisAgo <= _week_value) {
      return "${DateFormat("E '@' HH:mm").format(this)}";
    } else if (DateTime.now().year == year) {
      return "${DateFormat("MMM d '@' HH:mm").format(this)}";
    } else {
      return "${DateFormat("yyyy MMM d '@' HH:mm").format(this)}";
    }
  }
}
