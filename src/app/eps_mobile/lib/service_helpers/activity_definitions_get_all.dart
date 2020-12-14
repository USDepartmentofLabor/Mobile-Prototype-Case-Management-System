import 'dart:convert';
import 'package:eps_mobile/models/activity_definition.dart';
import 'package:eps_mobile/models/activity_definition_document.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;

class ActivityDefinitionsGetAll {
  String getClassName() {
    return this.runtimeType.toString();
  }

  static Future<Tuple3<bool, List<String>, List<ActivityDefinition>>> getAll(
    String jwtToken,
    String serviceUrl,
    bool useHttps,
  ) async {
    var errors = List<String>();

    Uri logInUri;

    String url = '/activity_definitions';

    if (useHttps) {
      logInUri = Uri.https(serviceUrl, url);
    } else {
      logInUri = Uri.http(serviceUrl, url);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + jwtToken
    };

    final response = await http.get(logInUri, headers: headers);

    if (response.statusCode == 200) {
      var objects = List<ActivityDefinition>();

      for (var objectData in json.decode(response.body)) {
        var object = ActivityDefinition();

        // id
        var idKey = 'id';
        if (objectData.containsKey(idKey)) {
          object.id = objectData[idKey];
        }

        // name
        var nameKey = 'name';
        if (objectData.containsKey(nameKey)) {
          object.name = objectData[nameKey];
        }

        // description
        var descriptionKey = 'description';
        if (objectData.containsKey(descriptionKey)) {
          object.description = objectData[descriptionKey];
        }

        // custom field data
        var customFieldsKey = 'custom_fields';
        if (objectData.containsKey(customFieldsKey)) {
          var data = objectData[customFieldsKey];
          Map<String, List> customFieldMap = {'data': []};
          var list = [];
          for (var customField in data) {
            list.add(customField);
          }
          customFieldMap['data'] = list;
          object.customFieldData = jsonEncode(customFieldMap);
        }

        // surveys
        object.surveys = List<Survey>();
        var surveysKey = 'surveys';
        if (objectData.containsKey(surveysKey)) {
          var surveyData = objectData[surveysKey];
          for (var survey in surveyData) {
            var surveyObj = Survey();

            var surveyIdKey = 'id';
            if (survey.containsKey(surveyIdKey)) {
              surveyObj.id = survey[surveyIdKey];
            }

            var surveyNameKey = 'name';
            if (survey.containsKey(surveyNameKey)) {
              surveyObj.name = survey[surveyNameKey];
            }

            object.surveys.add(surveyObj);
          }
        }

        // documents
        object.docs = List<ActivityDefinitionDocument>();
        var documentsKey = 'documents';
        if (objectData.containsKey(documentsKey)) {
          var documentData = objectData[documentsKey];
          for (var doc in documentData) {
            var docObj = ActivityDefinitionDocument();

            var docIdKey = 'id';
            if (doc.containsKey(docIdKey)) {
              docObj.id = doc[docIdKey];
            }

            var docnameKey = 'name';
            if (doc.containsKey(docnameKey)) {
              docObj.name = doc[docnameKey];
            }

            var docdescriptionKey = 'description';
            if (doc.containsKey(docdescriptionKey)) {
              docObj.description = doc[docdescriptionKey];
            }

            var docdisreqKey = 'is_required';
            if (doc.containsKey(docdisreqKey)) {
              docObj.isRequired = doc[docdisreqKey] == 'true' ? true : false;
            }

            docObj.activityDefinitionId = object.id;

            object.docs.add(docObj);
          }
        }

        // case definition id
        var caseDefinitionKey = 'case_definition';
        if (objectData.containsKey(caseDefinitionKey)) {
          var caseDefinitionIdKey = 'id';
          if (objectData[caseDefinitionKey].containsKey(caseDefinitionIdKey)) {
            object.caseDefinitionId =
                objectData[caseDefinitionKey][caseDefinitionIdKey];
          }
        }

        // createdAt
        var createdAtKey = 'created_at';
        if (objectData.containsKey(createdAtKey)) {
          object.createdAt = DateTime.parse(objectData[createdAtKey]);
        }

        // createdBy
        var createdByKey = 'created_by';
        if (objectData.containsKey(createdByKey)) {
          var createdByIdKey = 'id';
          if (objectData[createdByKey].containsKey(createdByIdKey)) {
            object.createdBy = objectData[createdByKey][createdByIdKey];
          }
        }

        // updatedAt
        var updatedAtKey = 'updated_at';
        if (objectData.containsKey(updatedAtKey)) {
          object.updatedAt = DateTime.parse(objectData[updatedAtKey]);
        }

        // updatedBy
        var updatedByKey = 'updated_by';
        if (objectData.containsKey(updatedByKey)) {
          var updatedByIdKey = 'id';
          if (objectData[updatedByKey].containsKey(updatedByIdKey)) {
            object.updatedBy = objectData[updatedByKey][updatedByIdKey];
          }
        }

        objects.add(object);
      }

      return Tuple3<bool, List<String>, List<ActivityDefinition>>(
        true,
        errors,
        objects,
      );
    } else {
      // get the error code and string
      print(response.bodyBytes.toString());
      errors.add(
        response.statusCode.toString(),
      );
      errors.add(
        response.body,
      );
    }

    return Tuple3<bool, List<String>, List<ActivityDefinition>>(
      false,
      errors,
      null,
    );
  }
}
