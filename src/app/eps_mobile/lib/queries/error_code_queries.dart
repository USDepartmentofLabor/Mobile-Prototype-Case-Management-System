import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/error_code.dart';

class ErrorCodeQueries {
  static Future<void> insertErrorCode(
    Database database,
    ErrorCode errorCode,
  ) async {
    await database.insert(
      ErrorCode.getTableName(),
      errorCode.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteErrorCode(
    Database database,
    int code,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + ErrorCode.getTableName() + ' WHERE code = ?',
      [code.toString()],
    );
  }

  static Future<List<int>> getErrorCodeCodes(
    Database database,
  ) async {
    var list = new List<int>();
    List<Map> data = await database
        .rawQuery('SELECT code FROM ' + ErrorCode.getTableName() + ';');
    for (var item in data) {
      if (item.containsKey('code')) {
        list.add(item['code']);
      }
    }
    return list;
  }
}
