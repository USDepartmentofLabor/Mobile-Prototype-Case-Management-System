import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/activity_definition_survey.dart';

class ActivityDefinitionSurveyQueries {
  static Future<void> insert(
    Database database,
    ActivityDefinitionSurvey caseDefinitionSurvey,
  ) async {
    await database.insert(
      ActivityDefinitionSurvey.getTableName(),
      caseDefinitionSurvey.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> delete(
    Database database,
    int actDefId,
    int surveyId,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' +
          ActivityDefinitionSurvey.getTableName() +
          ' WHERE activityDefinitionId = $actDefId AND surveyId = $surveyId',
    );
  }

  static Future<List<ActivityDefinitionSurvey>>
      getActivityDefinitionSurveysByActivityDefinitionId(
    Database database,
    int caseDefinitionId,
  ) async {
    var query = 'SELECT * FROM ' +
        ActivityDefinitionSurvey.getTableName() +
        ' WHERE activityDefinitionId = ' +
        caseDefinitionId.toString() +
        ';';
    List<Map> result = await database.rawQuery(
      query,
    );
    var results = new List<ActivityDefinitionSurvey>();
    result.forEach((row) => results.add(ActivityDefinitionSurvey.fromMap(row)));
    return results;
  }
}
