import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/activity_definition.dart';

class ActivityDefinitionQueries {
  static Future<void> insertActivityDefinition(
    Database database,
    ActivityDefinition activityDefinition,
  ) async {
    await database.insert(
      ActivityDefinition.getTableName(),
      activityDefinition.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> delete(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + ActivityDefinition.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<List<ActivityDefinition>> getAllActivityDefinitions(
    Database database,
  ) async {
    var list = new List<ActivityDefinition>();
    List<Map> data = await database.rawQuery(
      'SELECT * FROM ' + ActivityDefinition.getTableName() + ';',
    );
    for (var item in data) {
      list.add(ActivityDefinition.fromMap(item));
    }
    return list;
  }

  static Future<ActivityDefinition> getActivityDefinitionById(
    Database database,
    int id,
  ) async {
    List<Map> data = await database.rawQuery(
      'SELECT * FROM ' +
          ActivityDefinition.getTableName() +
          ' WHERE id = ' +
          id.toString() +
          ';',
    );
    return ActivityDefinition.fromMap(data.first);
  }

  static Future<bool> getActivityDefinitionIdExistsLocal(
    Database database,
    int activityDefinitionId,
  ) async {
    var query = 'select COUNT(*) as COUNT from ' +
        ActivityDefinition.getTableName() +
        ' where id = ' +
        activityDefinitionId.toString() +
        ';';
    var count = Sqflite.firstIntValue(await database.rawQuery(
      query,
    ));
    return (count == 1);
  }
}
