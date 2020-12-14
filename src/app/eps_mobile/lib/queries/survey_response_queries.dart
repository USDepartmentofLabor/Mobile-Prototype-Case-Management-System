import 'dart:core';
import 'package:eps_mobile/models/survey.dart';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/survey_response.dart';

class SurveyResponseQueries {
  static Future<void> insertSurveyResponse(
    Database database,
    SurveyResponse surveyResponse,
  ) async {
    await database.insert(
      SurveyResponse.getTableName(),
      surveyResponse.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertSurveyResponseLocal(
    Database database,
    SurveyResponse surveyResponse,
  ) async {
    // get next id
    var id = 1;
    var count = Sqflite.firstIntValue(
      await database.rawQuery(
        'SELECT COUNT(*) ' + SurveyResponse.getAltTableName() + ';',
      ),
    );
    if (count > 1) {
      var idQuery = Sqflite.firstIntValue(
        await database.rawQuery(
          'SELECT MAX(id) from ' + SurveyResponse.getAltTableName() + ';',
        ),
      );
      id = idQuery + 1;
    }
    surveyResponse.id = id;
    await database.insert(
      SurveyResponse.getAltTableName(),
      surveyResponse.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteSurveyResponse(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + SurveyResponse.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<void> deleteSurveyResponseLocal(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + SurveyResponse.getAltTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<List<SurveyResponse>> getSurveyResponsesByDefIdServer(
    Database database,
    int surveyId,
  ) async {
    // get survey response by id only by server synced (non new local only)
    var query = SurveyResponse.getTableName() +
        ' WHERE surveyId = ' +
        surveyId.toString() +
        ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<SurveyResponse>();
    result.forEach((row) => results.add(SurveyResponse.fromMap(row)));
    return results;
  }

  static Future<List<SurveyResponse>> getSurveyResponsesByDefIdLocal(
    Database database,
    int surveyId,
  ) async {
    // get survey response by id only by server synced (non new local only)
    var query = SurveyResponse.getAltTableName() +
        ' where surveyId = ' +
        surveyId.toString() +
        ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<SurveyResponse>();
    result.forEach((row) => results.add(SurveyResponse.fromMap(row)));
    return results;
  }

  static Future<SurveyResponse> getSurveyResponseBySurveyResponseIdServer(
    Database database,
    int surveyResponseId,
  ) async {
    var query = SurveyResponse.getTableName() +
        ' WHERE id = ' +
        surveyResponseId.toString() +
        ';';
    var x = await database.query(query);
    if (x.length == 0) {
      return null;
    } else {
      List<Map> result = await database.query(
        query,
      );

      var results = new List<SurveyResponse>();
      result.forEach((row) => results.add(SurveyResponse.fromMap(row)));
      return results.first;
    }
  }

  static Future<int> getSurveyResponseCountBySurveyIdServerOnly(
    Database database,
    int surveyId,
  ) async {
    var query = 'select COUNT(*) as COUNT from ' +
        SurveyResponse.getTableName() +
        ' where surveyId = ' +
        surveyId.toString() +
        ';';
    return Sqflite.firstIntValue(await database.rawQuery(query));
  }

  static Future<int> getSurveyResponseCountBySurveyIdLocalOnly(
    Database database,
    int surveyId,
  ) async {
    var query = 'select COUNT(*) as COUNT from ' +
        SurveyResponse.getAltTableName() +
        ' where surveyId = ' +
        surveyId.toString() +
        ';';
    return Sqflite.firstIntValue(
      await database.rawQuery(query),
    );
  }

  static Future<int> getSurveyResponseCountBySurveyResponseIdServerOnly(
    Database database,
    int surveyResponseId,
  ) async {
    var query = 'select COUNT(*) as COUNT from survey_responses where id = ' +
        surveyResponseId.toString() +
        ';';
    return Sqflite.firstIntValue(
      await database.rawQuery(
        query,
      ),
    );
  }

  static Future<SurveyResponse> getSurveyResponseBySurveyResponseIdServerOnly(
    Database database,
    int surveyResponseId,
  ) async {
    // get survey response by id only by server synced (non new local only)
    var query = SurveyResponse.getTableName() +
        ' WHERE id = ' +
        surveyResponseId.toString() +
        ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<SurveyResponse>();
    result.forEach((row) => results.add(SurveyResponse.fromMap(row)));
    return results.first;
  }

  static Future<SurveyResponse> getSurveyResponseBySurveyResponseIdLocalOnly(
    Database database,
    int surveyResponseId,
  ) async {
    // get survey response by id only by server synced (non new local only)
    var query = SurveyResponse.getAltTableName() +
        ' WHERE id = ' +
        surveyResponseId.toString() +
        ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<SurveyResponse>();
    result.forEach((row) => results.add(SurveyResponse.fromMap(row)));
    return results.first;
  }

  static Future<List<SurveyResponse>> getSurveyResponsesLocalOnly(
    Database database,
  ) async {
    // get survey response by id only by server synced (non new local only)
    var query = SurveyResponse.getAltTableName();
    List<Map> result = await database.query(
      query,
    );
    var results = new List<SurveyResponse>();
    result.forEach((row) => results.add(SurveyResponse.fromMap(row)));
    return results;
  }

  static Future<List<SurveyResponse>> getSurveyResponsesBySurvey(
    Database database,
    Survey survey,
  ) async {
    var query = SurveyResponse.getTableName() +
        ' WHERE surveyId = ' +
        survey.id.toString() +
        ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<SurveyResponse>();
    result.forEach((row) => results.add(SurveyResponse.fromMap(row)));
    return results;
  }

  static Future<List<int>> getSurveyResponseIdsBySurvey(
    Database database,
    Survey survey,
  ) async {
    var query = SurveyResponse.getTableName() +
        ' WHERE surveyId = ' +
        survey.id.toString() +
        ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<int>();
    result.forEach((row) => results.add(SurveyResponse.fromMap(row).id));
    return results;
  }

  static Future<List<SurveyResponse>> getSurveyResponsesBySurveyNonArchived(
    Database database,
    Survey survey,
  ) async {
    var query = SurveyResponse.getTableName() +
        ' WHERE surveyId = ' +
        survey.id.toString() +
        ' AND ' +
        'isArchived = \'false\';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<SurveyResponse>();
    result.forEach((row) => results.add(SurveyResponse.fromMap(row)));
    return results;
  }

  static Future<List<SurveyResponse>> getSurveyResponsesBySurveyIdByCaseId(
    Database database,
    int surveyId,
    int caseId,
  ) async {
    var querySuffix = ' WHERE surveyId = ' +
        surveyId.toString() +
        ' AND sourceType = \'Case\'' +
        ' AND caseId = ' +
        caseId.toString() +
        ';';
    var localQuery = SurveyResponse.getAltTableName() + querySuffix;
    var syncedQuery = SurveyResponse.getTableName() + querySuffix;
    List<Map> localResult = await database.query(
      localQuery,
    );
    List<Map> syncedResult = await database.query(
      syncedQuery,
    );
    var results = new List<SurveyResponse>();
    localResult.forEach((row) => results.add(SurveyResponse.fromMap(row)));
    syncedResult.forEach((row) => results.add(SurveyResponse.fromMap(row)));
    return results;
  }
}
