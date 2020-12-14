import 'dart:core';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/case_definition.dart';

class CaseDefinitionQueries {
  static Future<void> insertCaseDefinition(
    Database database,
    CaseDefinition caseDefinition,
  ) async {
    await database.insert(
      CaseDefinition.getTableName(),
      caseDefinition.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> delete(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + CaseDefinition.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<List<CaseDefinition>> getAllCaseDefinitions(
    Database database,
  ) async {
    var list = new List<CaseDefinition>();
    List<Map> data = await database.rawQuery(
      'SELECT * FROM ' + CaseDefinition.getTableName() + ';',
    );
    for (var item in data) {
      list.add(CaseDefinition.fromMap(item));
    }
    return list;
  }

  static Future<List<CaseDefinition>> getAllCaseDefinitionsWithCaseCounts(
    Database database,
  ) async {
    var list = new List<CaseDefinition>();
    List<Map> data = await database.rawQuery(
      'SELECT * FROM ' + CaseDefinition.getTableName() + ';',
    );
    for (var item in data) {
      var caseDefinition = CaseDefinition.fromMap(item);
      // get the case counts
      var serverCount =
          await CaseDefinitionQueries.getCaseDefinitionCaseCountByIdServerOnly(
        database,
        caseDefinition.id,
      );
      var localCount =
          await CaseDefinitionQueries.getCaseDefinitionCaseCountByIdLocalOnly(
        database,
        caseDefinition.id,
      );
      caseDefinition.caseCount = serverCount + localCount;
      list.add(caseDefinition);
    }
    return list;
  }

  static Future<int> getCaseDefinitionCaseCountByIdServerOnly(
    Database database,
    int surveyId,
  ) async {
    var query = 'select COUNT(*) as COUNT from ' +
        CaseInstance.getTableName() +
        ' where caseDefinitionId = ' +
        surveyId.toString() +
        ';';
    return Sqflite.firstIntValue(
      await database.rawQuery(
        query,
      ),
    );
  }

  static Future<int> getCaseDefinitionCaseCountByIdLocalOnly(
    Database database,
    int surveyId,
  ) async {
    var query = 'select COUNT(*) as COUNT from ' +
        CaseInstance.getAltTableName() +
        ' where caseDefinitionId = ' +
        surveyId.toString() +
        ';';
    return Sqflite.firstIntValue(
      await database.rawQuery(
        query,
      ),
    );
  }

  // get count of case definitions by id to detect local existence
  static Future<int> getCaseDefinitionCountById(
    Database database,
    int caseDefinitionId,
  ) async {
    var query = 'select COUNT(*) as COUNT from ' +
        CaseDefinition.getTableName() +
        ' where id = ' +
        caseDefinitionId.toString() +
        ';';
    return Sqflite.firstIntValue(
      await database.rawQuery(
        query,
      ),
    );
  }

  static Future<CaseDefinition> getCaseDefinitionById(
    Database database,
    int caseDefinitionId,
  ) async {
    var query = CaseDefinition.getTableName() +
        ' WHERE id = ' +
        caseDefinitionId.toString() +
        ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<CaseDefinition>();
    result.forEach((row) => results.add(CaseDefinition.fromMap(row)));
    return results.first;
  }
}
