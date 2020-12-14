import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/activity_file.dart';

class ActivityFileQueries {
  static Future<void> insertActivityFile(
    Database database,
    ActivityFile activityFile,
  ) async {
    await database.insert(
      ActivityFile.getTableName(),
      activityFile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertLocalActivityFile(
    Database database,
    ActivityFile activityFile,
  ) async {
    await database.insert(
      ActivityFile.getAltTableName(),
      activityFile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> delete(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + ActivityFile.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<void> deleteLocal(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + ActivityFile.getAltTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<List<ActivityFile>> getActivityFilesByActivity(
    Database database,
    int activityId,
  ) async {
    var files = new List<ActivityFile>();
    var query = 'SELECT * FROM ' +
        ActivityFile.getTableName() +
        ' WHERE activityId = ' +
        activityId.toString() +
        ';';
    List<Map> data = await database.rawQuery(query);
    for (var obj in data) {
      files.add(ActivityFile.fromMap(obj));
    }
    return files;
  }

  static Future<List<ActivityFile>> getLocalActivityFilesByActivity(
    Database database,
    int activityId,
  ) async {
    var files = new List<ActivityFile>();
    var query = 'SELECT * FROM ' +
        ActivityFile.getAltTableName() +
        ' WHERE activityid = ' +
        activityId.toString() +
        ';';
    List<Map> data = await database.rawQuery(query);
    for (var obj in data) {
      files.add(ActivityFile.fromMap(obj));
    }
    return files;
  }
}
