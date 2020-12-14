import 'dart:core';
import 'package:eps_mobile/queries/survey_response_queries.dart';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/models/survey_response.dart';

class SurveyQueries {
  static Future<void> insertSurvey(
    Database database,
    Survey survey,
  ) async {
    await database.insert(
      Survey.getTableName(),
      survey.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteSurvey(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + SurveyResponse.getTableName() + ' WHERE surveyId = ?',
      [id.toString()],
    );
    await database.rawDelete(
      'DELETE FROM ' + Survey.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<List<Survey>> getAllSurveys(
    Database database,
  ) async {
    var list = new List<Survey>();
    List<Map> data =
        await database.rawQuery('SELECT * FROM ' + Survey.getTableName() + ';');
    for (var item in data) {
      list.add(Survey.fromMap(item));
    }
    return list;
  }

  static Future<List<Survey>> getAllSurveysWithResponseCounts(
    Database database,
  ) async {
    var list = new List<Survey>();
    List<Map> data = await database.rawQuery(
      'SELECT * FROM ' + Survey.getTableName() + ';',
    );
    for (var item in data) {
      var survey = Survey.fromMap(item);

      // get the response counts
      var serverCount = await SurveyResponseQueries
          .getSurveyResponseCountBySurveyIdServerOnly(
        database,
        survey.id,
      );
      var localCount =
          await SurveyResponseQueries.getSurveyResponseCountBySurveyIdLocalOnly(
        database,
        survey.id,
      );
      survey.responseCount = serverCount + localCount;
      list.add(survey);
    }
    return list;
  }

  // get count of survey by survey id to detext local existence
  static Future<int> getSurveyCountBySurveyId(
    Database database,
    int surveyId,
  ) async {
    var query = 'select COUNT(*) as COUNT from ' +
        Survey.getTableName() +
        ' where id = ' +
        surveyId.toString() +
        ';';
    return Sqflite.firstIntValue(
      await database.rawQuery(
        query,
      ),
    );
  }

  // get Survey object by id
  static Future<Survey> getSurveyBySurveyId(
    Database database,
    int surveyId,
  ) async {
    var query =
        Survey.getTableName() + ' WHERE id = ' + surveyId.toString() + ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<Survey>();
    result.forEach((row) => results.add(Survey.fromMap(row)));
    return results.first;
  }
}
