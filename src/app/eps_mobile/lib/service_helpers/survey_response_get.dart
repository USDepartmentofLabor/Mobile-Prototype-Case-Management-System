import 'dart:convert';
import 'package:eps_mobile/models/survey_response.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

class SurveyResponseGet {
  static Future<Tuple3<bool, List<String>, List<SurveyResponse>>>
      getAllBySurveyId(
    String jwtToken,
    String serviceUrl,
    bool useHttps,
    int surveyId,
  ) async {
    Uri logInUri;

    var path = '/surveys/' + surveyId.toString() + '/responses';

    if (useHttps) {
      logInUri = Uri.https(
        serviceUrl,
        path,
      );
    } else {
      logInUri = Uri.http(
        serviceUrl,
        path,
      );
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + jwtToken
    };

    final response = await http.get(logInUri, headers: headers);

    if (response.statusCode == 200) {
      var responses = List<SurveyResponse>();
      var responseData = json.decode(response.body);
      for (var surveyResponse in responseData) {
        var surveyResponseInstance = SurveyResponse();

        if (surveyResponse.containsKey('id')) {
          surveyResponseInstance.id = surveyResponse['id'];
        }

        if (surveyResponse.containsKey('survey')) {
          surveyResponseInstance.surveyId = surveyResponse['survey'];
        }

        if (surveyResponse.containsKey('structure')) {
          surveyResponseInstance.structure = surveyResponse['structure'];
        }

        if (surveyResponse.containsKey('status')) {
          var statusData = surveyResponse['status'];
          if (statusData.containsKey('id')) {
            var surveyResponseStatusId = statusData['id'];
            surveyResponseInstance.statusId = surveyResponseStatusId;
          }
        }

        if (surveyResponse.containsKey('source_type')) {
          surveyResponseInstance.sourceType = surveyResponse['source_type'];
        }

        if (surveyResponse.containsKey('case_id')) {
          surveyResponseInstance.caseId = surveyResponse['case_id'];
        }

        if (surveyResponse.containsKey('activity_id')) {
          surveyResponseInstance.activityId = surveyResponse['activity_id'];
        }

        if (surveyResponse.containsKey('created_at')) {
          surveyResponseInstance.createdAt =
              DateTime.parse(surveyResponse['created_at']);
        }

        if (surveyResponse.containsKey('updated_at')) {
          surveyResponseInstance.updatedAt =
              DateTime.parse(surveyResponse['updated_at']);
        }

        if (surveyResponse.containsKey('is_archived')) {
          surveyResponseInstance.isArchived = surveyResponse['is_archived'];
        }

        surveyResponseInstance.caseModelType = '';
        surveyResponseInstance.activityModelType = '';

        if (surveyResponseInstance.activityId != null) {
          surveyResponseInstance.activityModelType =
              SurveyResponseActivityModelType.ServerCaseServerActivity
                  .toString();
        }

        responses.add(surveyResponseInstance);
      }

      return Tuple3<bool, List<String>, List<SurveyResponse>>(
        true,
        List<String>(),
        responses,
      );
    } else {
      print('error');
    }

    return Tuple3<bool, List<String>, List<SurveyResponse>>(
      false,
      List<String>(),
      List<SurveyResponse>(),
    );
  }
}
