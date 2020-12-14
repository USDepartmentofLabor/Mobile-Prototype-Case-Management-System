import 'package:eps_mobile/models/activity_definition.dart';
import 'package:eps_mobile/models/activity_definition_survey.dart';
import 'package:eps_mobile/models/bool_list_string_tuple.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/queries/activity_definition_document_queries.dart';
import 'package:eps_mobile/queries/activity_definition_queries.dart';
import 'package:eps_mobile/queries/activity_definition_survey_queries.dart';
import 'package:eps_mobile/service_helpers/activity_definitions_get_all.dart';

class ActivityDefinitionsSync {
  static Future<BoolListStringTuple> fullSync(
    EpsState epsState,
  ) async {
    var rtn = BoolListStringTuple();

    try {
      var serverList = await ActivityDefinitionsGetAll.getAll(
        epsState.user.jwtToken,
        epsState.serviceInfo.url,
        epsState.serviceInfo.useHttps,
      );

      var success = false;

      if (serverList.item1 == true) {
        var sync = await syncFromServerList(
          epsState,
          serverList.item3,
        );
        success = sync.boolValue;
      }

      if (success) {
        rtn.boolValue = true;
        return rtn;
      } else {
        var errors = List<String>();
        var error = 'error in activity definitions sync';
        print(error);
        errors.add(error);
        rtn.boolValue = false;
        rtn.stringValues.addAll(errors);
        return rtn;
      }
    } catch (e) {
      var errors = List<String>();
      var error = 'error in activity definitions sync';
      print(error);
      errors.add(error);
      rtn.boolValue = false;
      rtn.stringValues.addAll(errors);
      return rtn;
    }
  }

  static Future<BoolListStringTuple> syncFromServerList(
    EpsState epsState,
    List<ActivityDefinition> activityDefinitions,
  ) async {
    var rtn = BoolListStringTuple();

    try {
      // server to local
      var serverIds = List<int>();
      for (var serveractivityDef in activityDefinitions) {
        await ActivityDefinitionQueries.insertActivityDefinition(
          epsState.database.database,
          serveractivityDef,
        );
        serverIds.add(serveractivityDef.id);

        // docs
        var docSync = await syncactivityDefinitionDocuments(
          epsState,
          serveractivityDef,
        );
        if (docSync.boolValue == false) {
          rtn.stringValues.addAll(docSync.stringValues);
          return rtn;
        }

        // surveys
        var surveysSync = await syncActivityDefinitionSurveys(
          epsState,
          serveractivityDef,
        );
        if (surveysSync.boolValue == false) {
          rtn.stringValues.addAll(surveysSync.stringValues);
          return rtn;
        }
      }

      // get all local
      var allLocal = await ActivityDefinitionQueries.getAllActivityDefinitions(
        epsState.database.database,
      );

      // delete local not on server
      for (var local in allLocal) {
        if (!serverIds.contains(local.id)) {
          ActivityDefinitionQueries.delete(
            epsState.database.database,
            local.id,
          );
        }
      }

      rtn.boolValue = true;
      return rtn;
    } catch (e) {
      var errors = List<String>();
      var error = 'error in activity definitions sync';
      print(error);
      errors.add(error);
      rtn.boolValue = false;
      rtn.stringValues.addAll(errors);
      return rtn;
    }
  }

  static Future<BoolListStringTuple> syncactivityDefinitionDocuments(
    EpsState epsState,
    ActivityDefinition activityDefinition,
  ) async {
    // simple sync by activity definition id

    var rtn = BoolListStringTuple();

    try {
      var serverIds = List<int>();

      // get all locals
      var existingLocal = await ActivityDefinitionDocumentQueries
          .getActivityDefinitionDocumentsByActivityDefinitionId(
        epsState.database.database,
        activityDefinition.id,
      );

      // server adds/updates
      for (var object in activityDefinition.docs) {
        serverIds.add(object.id);
        ActivityDefinitionDocumentQueries.insertActivityDefinitionDocument(
          epsState.database.database,
          object,
        );
      }

      // delete locals not on server
      for (var localObject in existingLocal) {
        if (!serverIds.contains(localObject.id)) {
          ActivityDefinitionDocumentQueries.delete(
            epsState.database.database,
            localObject.id,
          );
        }
      }

      rtn.boolValue = true;
      return rtn;
    } catch (e) {
      rtn.boolValue = false;
      rtn.stringValues.add('error act activity def doc');
      return rtn;
    }
  }

  static Future<BoolListStringTuple> syncActivityDefinitionSurveys(
    EpsState epsState,
    ActivityDefinition activityDefinition,
  ) async {
    // simple sync by activity definition id

    var rtn = BoolListStringTuple();

    try {
      var serverIds = List<int>();

      // get all locals
      var existingLocal = await ActivityDefinitionSurveyQueries
          .getActivityDefinitionSurveysByActivityDefinitionId(
        epsState.database.database,
        activityDefinition.id,
      );

      // server adds/updates
      for (var object in activityDefinition.surveys) {
        serverIds.add(object.id);
        var newObj = ActivityDefinitionSurvey();
        newObj.activityDefinitionId = activityDefinition.id;
        newObj.surveyId = object.id;
        ActivityDefinitionSurveyQueries.insert(
          epsState.database.database,
          newObj,
        );
      }

      // delete locals not on server
      for (var localObject in existingLocal) {
        if (!serverIds.contains(localObject.surveyId)) {
          ActivityDefinitionSurveyQueries.delete(
            epsState.database.database,
            localObject.activityDefinitionId,
            localObject.surveyId,
          );
        }
      }

      rtn.boolValue = true;
      return rtn;
    } catch (e) {
      rtn.boolValue = false;
      rtn.stringValues.add('error act activity def survey');
      return rtn;
    }
  }
}
