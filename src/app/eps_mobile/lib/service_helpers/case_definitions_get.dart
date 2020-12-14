import 'dart:convert';
import 'package:eps_mobile/models/case_definition_document.dart';
import 'package:eps_mobile/models/case_definition_survey.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/case_definition.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class CaseDefinitionsGet {
  EpsState epsState;

  CaseDefinitionsGet(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple2<bool, List<CaseDefinition>>> getCaseDefinitions(
    String serviceUrl,
    bool useHttps,
  ) async {
    Uri logInUri;

    String url = '/case_definitions/';

    if (useHttps) {
      logInUri = Uri.https(serviceUrl, url);
    } else {
      logInUri = Uri.http(serviceUrl, url);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    final response = await http.get(logInUri, headers: headers);

    var caseDefinitions = new List<CaseDefinition>();

    if (response.statusCode == 200) {
      for (var caseDefinitionData in json.decode(response.body)) {
        var caseDefinition = new CaseDefinition();
        if (caseDefinitionData.containsKey('id')) {
          caseDefinition.id = caseDefinitionData['id'];
        }
        if (caseDefinitionData.containsKey('name')) {
          caseDefinition.name = caseDefinitionData['name'];
        }
        if (caseDefinitionData.containsKey('description')) {
          caseDefinition.description = caseDefinitionData['description'];
        }
        if (caseDefinitionData.containsKey('key')) {
          caseDefinition.key = caseDefinitionData['key'];
        }
        if (caseDefinitionData.containsKey('documents')) {
          var documentsData = caseDefinitionData['documents'];
          for (var documentData in documentsData) {
            var document = new CaseDefinitionDocument();
            if (documentData.containsKey('id')) {
              document.id = documentData['id'];
            }
            if (documentData.containsKey('name')) {
              document.name = documentData['name'];
            }
            if (documentData.containsKey('description')) {
              document.description = documentData['description'];
            }
            if (documentData.containsKey('is_required')) {
              document.isRequired = documentData['is_required'];
            }
            document.caseDefinitionId = caseDefinition.id;
            caseDefinition.documents.add(document);
          }
        }
        if (caseDefinitionData.containsKey('surveys')) {
          var surveysData = caseDefinitionData['surveys'];
          for (var surveyData in surveysData) {
            var caseDefinitionSurvey = new CaseDefinitionSurvey();
            if (surveyData.containsKey('id')) {
              caseDefinitionSurvey.surveyId = surveyData['id'];
            }
            caseDefinitionSurvey.caseDefinitionId = caseDefinition.id;
            caseDefinition.surveys.add(caseDefinitionSurvey);
          }
        }
        if (caseDefinitionData.containsKey('created_at')) {
          caseDefinition.createdAt =
              DateTime.parse(caseDefinitionData['created_at']);
        }
        if (caseDefinitionData.containsKey('updated_at')) {
          caseDefinition.updatedAt =
              DateTime.parse(caseDefinitionData['updated_at']);
        }

        // Custom Fields
        var customFieldsKey = 'custom_fields';
        if (caseDefinitionData.containsKey(customFieldsKey)) {
          var data = caseDefinitionData[customFieldsKey];
          Map<String, List> customFieldMap = {'data': []};
          var list = [];
          for (var customField in data) {
            list.add(customField);
          }
          customFieldMap['data'] = list;
          caseDefinition.customFieldData = jsonEncode(customFieldMap);
        }

        caseDefinitions.add(caseDefinition);
      }
      return new Tuple2<bool, List<CaseDefinition>>(true, caseDefinitions);
    }

    // failure
    return Tuple2<bool, List<CaseDefinition>>(false, null);
  }
}
