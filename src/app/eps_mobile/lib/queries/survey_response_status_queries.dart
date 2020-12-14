import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/survey_response_status.dart';

class SurveyResponseStatusQueries {
  static Future<void> insertSurveyResponseStatus(
    Database database,
    SurveyResponseStatus surveyResponseStatus,
  ) async {
    await database.insert(
      SurveyResponseStatus.getTableName(),
      surveyResponseStatus.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteSurveyResponseStatus(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
        'DELETE FROM ' + SurveyResponseStatus.getTableName() + ' WHERE id = ?',
        [id.toString()]);
  }

  static Future<List<SurveyResponseStatus>> getAll(
    Database database,
  ) async {
    var list = new List<SurveyResponseStatus>();
    List<Map> data = await database
        .rawQuery('SELECT * FROM ' + SurveyResponseStatus.getTableName() + ';');
    for (var item in data) {
      list.add(SurveyResponseStatus.fromMap(item));
    }
    return list;
  }

  static Future<List<int>> getSurveyResponseStatusIds(
    Database database,
  ) async {
    var list = new List<int>();
    List<Map> data = await database.rawQuery(
        'SELECT id FROM ' + SurveyResponseStatus.getTableName() + ';');
    for (var item in data) {
      if (item.containsKey('id')) {
        list.add(item['id']);
      }
    }
    return list;
  }

  static Future<bool> getSurveyResponseStatusIdExists(
    Database database,
    int id,
  ) async {
    var query = 'SELECT COUNT(*) AS COUNT FROM ' +
        SurveyResponseStatus.getTableName() +
        ' WHERE id = ' +
        id.toString();
    var count = Sqflite.firstIntValue(await database.rawQuery(query));
    return count == 1;
  }
}
