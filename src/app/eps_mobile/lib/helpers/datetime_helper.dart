import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateTimeHelper {
  static String getUpdatedAtDisplay(DateTime dateTime) {
    return timeago.format(dateTime);
  }

  static String getDateTimeAsYYYYMMDDHHMMSSString(DateTime dateTime) {
    var formatter = new DateFormat('yyyy-MM-dd hh:mm:ss');
    return formatter.format(dateTime);
  }

  static String getDateTimeAsYYYYMMDDString(DateTime dateTime) {
    var formatter = new DateFormat('yyyy-MM-dd');
    return formatter.format(dateTime);
  }
}
