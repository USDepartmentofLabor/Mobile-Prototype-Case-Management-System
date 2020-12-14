import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/activity_definition_document.dart';

class ActivityDefinitionDocumentQueries {
  static Future<void> insertActivityDefinitionDocument(
    Database database,
    ActivityDefinitionDocument activityDefinitionDocument,
  ) async {
    await database.insert(
      ActivityDefinitionDocument.getTableName(),
      activityDefinitionDocument.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> delete(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' +
          ActivityDefinitionDocument.getTableName() +
          ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<List<ActivityDefinitionDocument>>
      getActivityDefinitionDocumentsByActivityDefinitionId(
    Database database,
    int activityDefinitionId,
  ) async {
    var query = 'SELECT * FROM ' +
        ActivityDefinitionDocument.getTableName() +
        ' WHERE activityDefinitionId = ' +
        activityDefinitionId.toString() +
        ';';
    List<Map> result = await database.rawQuery(
      query,
    );
    var results = new List<ActivityDefinitionDocument>();
    result
        .forEach((row) => results.add(ActivityDefinitionDocument.fromMap(row)));
    return results;
  }

  static Future<int> getActivityDefinitionDocumentCountById(
    Database database,
    int activityDefinitionId,
    int activityDefinitionDocumentId,
  ) async {
    var query = 'select COUNT(*) as COUNT from ' +
        ActivityDefinitionDocument.getTableName() +
        ' where id = ' +
        activityDefinitionDocumentId.toString() +
        ' and activityDefinitionId = ' +
        activityDefinitionId.toString() +
        ';';
    return Sqflite.firstIntValue(
      await database.rawQuery(
        query,
      ),
    );
  }
}
