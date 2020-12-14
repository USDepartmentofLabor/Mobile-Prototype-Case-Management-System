import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/case_status.dart';

class CaseStatusQueries {
  static Future<void> insertCaseStatus(
    Database database,
    CaseStatus caseStatus,
  ) async {
    await database.insert(
      CaseStatus.getTableName(),
      caseStatus.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteCaseStatus(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
        'DELETE FROM ' + CaseStatus.getTableName() + ' WHERE id = ?',
        [id.toString()]);
  }

  static Future<List<CaseStatus>> getAllCaseStatuses(
    Database database,
  ) async {
    var list = new List<CaseStatus>();
    List<Map> data = await database
        .rawQuery('SELECT * FROM ' + CaseStatus.getTableName() + ';');
    for (var item in data) {
      list.add(CaseStatus.fromMap(item));
    }
    return list;
  }

  static Future<CaseStatus> getCaseStatusById(
    Database database,
    int id,
  ) async {
    var query =
        CaseStatus.getTableName() + ' WHERE id = ' + id.toString() + ';';
    List<Map> result = await database.query(query);
    var results = new List<CaseStatus>();
    result.forEach((row) => results.add(CaseStatus.fromMap(row)));
    return results.first;
  }

  static Future<List<int>> getCaseStatusIds(
    Database database,
  ) async {
    var list = new List<int>();
    List<Map> data = await database
        .rawQuery('SELECT id FROM ' + CaseStatus.getTableName() + ';');
    for (var item in data) {
      if (item.containsKey('id')) {
        list.add(item['id']);
      }
    }
    return list;
  }
}
