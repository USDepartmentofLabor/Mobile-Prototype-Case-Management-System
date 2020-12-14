import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/case_definition_survey.dart';
import 'package:eps_mobile/models/case_definition.dart';

class CaseDefinitionSurveyQueries {
  static Future<void> insertCaseDefinitionSurvey(
    Database database,
    CaseDefinitionSurvey caseDefinitionSurvey,
  ) async {
    await database.insert(
      CaseDefinitionSurvey.getTableName(),
      caseDefinitionSurvey.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> delete(
    Database database,
    int caseDefId,
    int surveyId,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' +
          CaseDefinitionSurvey.getTableName() +
          ' WHERE caseDefinitionId = $caseDefId AND surveyId = $surveyId',
    );
  }

  static Future<List<CaseDefinitionSurvey>>
      getCaseDefinitionSurveysByCaseDefinitionId(
    Database database,
    int caseDefinitionId,
  ) async {
    var query = 'SELECT * FROM ' +
        CaseDefinitionSurvey.getTableName() +
        ' WHERE caseDefinitionId = ' +
        caseDefinitionId.toString() +
        ';';
    List<Map> result = await database.rawQuery(
      query,
    );
    var results = new List<CaseDefinitionSurvey>();
    result.forEach((row) => results.add(CaseDefinitionSurvey.fromMap(row)));
    return results;
  }

  static Future<bool> caseDefinitionSurveyExists(
    Database database,
    CaseDefinitionSurvey caseDefinitionSurvey,
  ) async {
    var query = 'SELECT COUNT(*) AS COUNT FROM ' +
        CaseDefinitionSurvey.getTableName() +
        ' WHERE ' +
        'caseDefinitionId = ' +
        caseDefinitionSurvey.caseDefinitionId.toString() +
        ' AND ' +
        'surveyId = ' +
        caseDefinitionSurvey.surveyId.toString() +
        ';';
    return Sqflite.firstIntValue(await database.rawQuery(
          query,
        )) !=
        1;
  }

  static Future<List<CaseDefinitionSurvey>>
      getCaseDefinitionSurveysByCaseDefinition(
    Database database,
    CaseDefinition caseDefinition,
  ) async {
    var query = CaseDefinitionSurvey.getTableName() +
        ' WHERE caseDefinitionId = ' +
        caseDefinition.id.toString() +
        ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<CaseDefinitionSurvey>();
    result.forEach((row) => results.add(CaseDefinitionSurvey.fromMap(row)));
    return results;
  }
}
