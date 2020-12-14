import 'package:eps_mobile/models/bool_list_string_tuple.dart';
import 'package:eps_mobile/models/case_definition.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/queries/case_definition_document_queries.dart';
import 'package:eps_mobile/queries/case_definition_queries.dart';
import 'package:eps_mobile/queries/case_definition_survey_queries.dart';
import 'package:eps_mobile/service_helpers/case_definitions_get.dart';

class CaseDefinitionsSync {
  static Future<BoolListStringTuple> fullSync(
    EpsState epsState,
  ) async {
    var rtn = BoolListStringTuple();

    try {
      var serverList = await CaseDefinitionsGet(epsState).getCaseDefinitions(
        epsState.serviceInfo.url,
        epsState.serviceInfo.useHttps,
      );

      var success = false;

      if (serverList.item1 == true) {
        var sync = await syncFromServerList(
          epsState,
          serverList.item2,
        );
        success = sync.boolValue;
      }

      if (success) {
        rtn.boolValue = true;
        return rtn;
      } else {
        var errors = List<String>();
        var error = 'error in case definitions sync';
        print(error);
        errors.add(error);
        rtn.boolValue = false;
        rtn.stringValues.addAll(errors);
        return rtn;
      }
    } catch (e) {
      var errors = List<String>();
      var error = 'error in case definitions sync';
      print(error);
      errors.add(error);
      rtn.boolValue = false;
      rtn.stringValues.addAll(errors);
      return rtn;
    }
  }

  static Future<BoolListStringTuple> syncFromServerList(
    EpsState epsState,
    List<CaseDefinition> caseDefinitions,
  ) async {
    var rtn = BoolListStringTuple();

    try {
      // server to local
      var serverIds = List<int>();
      for (var serverCaseDef in caseDefinitions) {
        await CaseDefinitionQueries.insertCaseDefinition(
          epsState.database.database,
          serverCaseDef,
        );
        serverIds.add(serverCaseDef.id);

        // docs
        var docSync = await syncCaseDefinitionDocuments(
          epsState,
          serverCaseDef,
        );
        if (docSync.boolValue == false) {
          rtn.stringValues.addAll(docSync.stringValues);
          return rtn;
        }

        // surveys
        var surveysSync = await syncCaseDefinitionSurveys(
          epsState,
          serverCaseDef,
        );
        if (surveysSync.boolValue == false) {
          rtn.stringValues.addAll(surveysSync.stringValues);
          return rtn;
        }
      }

      // get all local
      var allLocal = await CaseDefinitionQueries.getAllCaseDefinitions(
        epsState.database.database,
      );

      // delete local not on server
      for (var local in allLocal) {
        if (!serverIds.contains(local.id)) {
          CaseDefinitionQueries.delete(
            epsState.database.database,
            local.id,
          );
        }
      }

      rtn.boolValue = true;
      return rtn;
    } catch (e) {
      var errors = List<String>();
      var error = 'error in case definitions sync';
      print(error);
      errors.add(error);
      rtn.boolValue = false;
      rtn.stringValues.addAll(errors);
      return rtn;
    }
  }

  static Future<BoolListStringTuple> syncCaseDefinitionDocuments(
    EpsState epsState,
    CaseDefinition caseDefinition,
  ) async {
    // simple sync by case definition id

    var rtn = BoolListStringTuple();

    try {
      var serverIds = List<int>();

      // get all locals
      var existingLocal = await CaseDefinitionDocumentQueries
          .getCaseDefinitionDocumentsByCaseDefinitionId(
        epsState.database.database,
        caseDefinition.id,
      );

      // server adds/updates
      for (var object in caseDefinition.documents) {
        serverIds.add(object.id);
        CaseDefinitionDocumentQueries.insertCaseDefinitionDocument(
          epsState.database.database,
          object,
        );
      }

      // delete locals not on server
      for (var localObject in existingLocal) {
        if (!serverIds.contains(localObject.id)) {
          CaseDefinitionDocumentQueries.delete(
            epsState.database.database,
            localObject.id,
          );
        }
      }

      rtn.boolValue = true;
      return rtn;
    } catch (e) {
      rtn.boolValue = false;
      rtn.stringValues.add('error sync case def doc');
      return rtn;
    }
  }

  static Future<BoolListStringTuple> syncCaseDefinitionSurveys(
    EpsState epsState,
    CaseDefinition caseDefinition,
  ) async {
    // simple sync by case definition id

    var rtn = BoolListStringTuple();

    try {
      var serverIds = List<int>();

      // get all locals
      var existingLocal = await CaseDefinitionSurveyQueries
          .getCaseDefinitionSurveysByCaseDefinitionId(
        epsState.database.database,
        caseDefinition.id,
      );

      // server adds/updates
      for (var object in caseDefinition.surveys) {
        serverIds.add(object.surveyId);
        CaseDefinitionSurveyQueries.insertCaseDefinitionSurvey(
          epsState.database.database,
          object,
        );
      }

      // delete locals not on server
      for (var localObject in existingLocal) {
        if (!serverIds.contains(localObject.surveyId)) {
          CaseDefinitionSurveyQueries.delete(
            epsState.database.database,
            localObject.caseDefinitionId,
            localObject.surveyId,
          );
        }
      }

      rtn.boolValue = true;
      return rtn;
    } catch (e) {
      rtn.boolValue = false;
      rtn.stringValues.add('error sync case def survey');
      return rtn;
    }
  }
}
