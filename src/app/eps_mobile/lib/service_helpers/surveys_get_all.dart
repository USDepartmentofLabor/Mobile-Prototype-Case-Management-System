import 'dart:convert';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/queries/survey_queries.dart';
import 'package:eps_mobile/queries/survey_response_queries.dart';
import 'package:eps_mobile/service_helpers/get_survey_response.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class SurveysGetAll {
  EpsState epsState;

  SurveysGetAll(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple2<bool, List<Survey>>> getAllSurveys(
    String serviceUrl,
    bool useHttps,
  ) async {
    Uri logInUri;

    if (useHttps) {
      logInUri = Uri.https(serviceUrl, '/surveys/');
    } else {
      logInUri = Uri.http(serviceUrl, '/surveys/');
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    final response = await http.get(logInUri, headers: headers);

    if (response.statusCode == 200) {
      var surveys = new List<Survey>();
      var responseData = json.decode(response.body);
      for (var surveyObject in responseData) {
        var survey = new Survey();
        if (surveyObject.containsKey('id')) {
          survey.id = surveyObject['id'];
        }
        if (surveyObject.containsKey('name')) {
          survey.name = surveyObject['name'];
        }
        if (surveyObject.containsKey('is_archived')) {
          survey.isArchived =
              surveyObject['is_archived'] == 'true' ? true : false;
        }
        if (surveyObject.containsKey('structure')) {
          survey.structure.addAll(surveyObject['structure']);
        }
        if (surveyObject.containsKey('created_at')) {
          survey.createdAt = DateTime.parse(surveyObject['created_at']);
        }
        if (surveyObject.containsKey('updated_at')) {
          survey.updatedAt = DateTime.parse(surveyObject['updated_at']);
        }

        if (surveyObject.containsKey('created_by')) {
          if (surveyObject['created_by'].containsKey('id')) {
            survey.createdBy = surveyObject['created_by']['id'];
          }
        }

        if (surveyObject.containsKey('updated_by')) {
          if (surveyObject['updated_by'].containsKey('id')) {
            survey.updatedBy = surveyObject['updated_by']['id'];
          }
        }

        surveys.add(survey);
      }
      return Tuple2<bool, List<Survey>>(true, surveys);
    }

    // failure
    return Tuple2<bool, List<Survey>>(false, null);
  }

  Future<Tuple2<bool, List<Survey>>> getAllSurveysWithResponses(
    String serviceUrl,
    bool useHttps,
  ) async {
    Uri logInUri;

    if (useHttps) {
      logInUri = Uri.https(serviceUrl, '/surveys/');
    } else {
      logInUri = Uri.http(serviceUrl, '/surveys/');
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    final response = await http.get(logInUri, headers: headers);

    if (response.statusCode == 200) {
      var existingSurveyIds = new List<int>();
      var surveys = new List<Survey>();
      var responseData = json.decode(response.body);
      for (var surveyObject in responseData) {
        var survey = new Survey();
        if (surveyObject.containsKey('id')) {
          survey.id = surveyObject['id'];
          existingSurveyIds.add(survey.id);
        }
        if (surveyObject.containsKey('name')) {
          survey.name = surveyObject['name'];
        }
        if (surveyObject.containsKey('structure')) {
          survey.structure.addAll(surveyObject['structure']);
        }
        if (surveyObject.containsKey('created_at')) {
          survey.createdAt = DateTime.parse(surveyObject['created_at']);
        }
        if (surveyObject.containsKey('updated_at')) {
          survey.updatedAt = DateTime.parse(surveyObject['updated_at']);
        }
        var existingResponseIds = new List<int>();
        if (surveyObject['responses'] != null) {
          for (var responseId in surveyObject['responses']) {
            // get responses
            var getResponseData = new GetSurveyResponse(epsState);
            var responseResult = await getResponseData.getSurveyResponse(
                survey,
                responseId,
                epsState.serviceInfo.url,
                epsState.serviceInfo.useHttps);
            if (responseResult.item1) {
              SurveyResponseQueries.insertSurveyResponse(
                epsState.database.database,
                responseResult.item2,
              );
              survey.responseCount++;
              if (responseResult.item2.isArchived == false) {
                survey.responseCountNonArchived++;
              }
              existingResponseIds.add(responseId);
            }
          }
        }
        // delete old responses
        for (var localSurveyResponse
            in await SurveyResponseQueries.getSurveyResponsesBySurvey(
          epsState.database.database,
          survey,
        )) {
          if (!existingResponseIds.contains(localSurveyResponse.id)) {
            await SurveyResponseQueries.deleteSurveyResponse(
              epsState.database.database,
              localSurveyResponse.id,
            );
          }
        }

        surveys.add(survey);
      }

      // remove local surveys not on survey
      for (var localSurvey
          in await SurveyQueries.getAllSurveys(epsState.database.database)) {
        if (!existingSurveyIds.contains(localSurvey.id)) {
          SurveyQueries.deleteSurvey(
            epsState.database.database,
            localSurvey.id,
          );
        }
      }

      return Tuple2<bool, List<Survey>>(true, surveys);
    }

    // failure
    return Tuple2<bool, List<Survey>>(false, null);
  }
}
