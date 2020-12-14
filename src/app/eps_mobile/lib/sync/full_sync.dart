import 'package:eps_mobile/models/bool_list_string_tuple.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/queries/survey_queries.dart';
import 'package:eps_mobile/sync/activities_sync.dart';
import 'package:eps_mobile/sync/activity_definitions_sync.dart';
import 'package:eps_mobile/sync/case_definitions_sync.dart';
import 'package:eps_mobile/sync/cases_sync.dart';
import 'package:eps_mobile/sync/lookups_sync.dart';
import 'package:eps_mobile/sync/projects_sync.dart';
import 'package:eps_mobile/sync/survey_responses_sync.dart';
import 'package:eps_mobile/sync/surveys_sync.dart';
import 'package:eps_mobile/sync/users_sync.dart';

class FullSync {
  static Future<BoolListStringTuple> fullSync(
    EpsState epsState,
  ) async {
    var rtn = BoolListStringTuple();
    rtn.boolValue = false;

    // lookups
    // - case statuses
    // - permissions
    // - survey response statuses
    // - user roles
    var lookupsFullSyncResult = await LookupsSync.fullSync(epsState);
    if (lookupsFullSyncResult.boolValue == false) {
      rtn.boolValue = false;
      rtn.stringValues.addAll(
        lookupsFullSyncResult.stringValues,
      );
      return rtn;
    }

    // users
    var usersFullSyncResult = await UsersSync.fullSync(epsState);
    if (usersFullSyncResult.boolValue == false) {
      rtn.boolValue = false;
      rtn.stringValues.addAll(
        usersFullSyncResult.stringValues,
      );
      return rtn;
    }

    // project(s)
    var projectsFullSyncResult = await ProjectsSync.fullsync(
      epsState,
    );
    if (projectsFullSyncResult.boolValue == false) {
      rtn.boolValue = false;
      rtn.stringValues.addAll(
        projectsFullSyncResult.stringValues,
      );
      return rtn;
    }

    // survey definitions
    var surveysFullSyncResult = await SurveysSync.fullSync(
      epsState,
    );
    if (surveysFullSyncResult.boolValue == false) {
      rtn.boolValue = false;
      rtn.stringValues.addAll(
        surveysFullSyncResult.stringValues,
      );
      return rtn;
    }

    // survey responses
    var surveyDefinitions = await SurveyQueries.getAllSurveys(
      epsState.database.database,
    );
    var surveyResponsesFullSyncResult = await SurveyResponsesSync.fullSync(
      epsState,
      surveyDefinitions,
    );
    if (surveyResponsesFullSyncResult.boolValue == false) {
      rtn.boolValue = false;
      rtn.stringValues.addAll(
        surveyResponsesFullSyncResult.stringValues,
      );
      return rtn;
    }

    // case definitions
    // - documents
    // - surveys
    var caseDefinitionsSync = await CaseDefinitionsSync.fullSync(
      epsState,
    );
    if (caseDefinitionsSync.boolValue == false) {
      rtn.boolValue = false;
      rtn.stringValues.addAll(
        caseDefinitionsSync.stringValues,
      );
      return rtn;
    }

    // activity definitions
    // - documents
    // - surveys
    var activityDefinitionsSync = await ActivityDefinitionsSync.fullSync(
      epsState,
    );
    if (activityDefinitionsSync.boolValue == false) {
      rtn.boolValue = false;
      rtn.stringValues.addAll(
        activityDefinitionsSync.stringValues,
      );
      return rtn;
    }

    // cases
    // - notes
    // - files
    var casesSync = await CasesSync.fullSync(
      epsState,
    );
    if (casesSync.boolValue == false) {
      rtn.boolValue = false;
      rtn.stringValues.addAll(
        casesSync.stringValues,
      );
      return rtn;
    }

    // activities
    var activitiesSync = await ActivitiesSync.fullSync(
      epsState,
    );
    if (activitiesSync.boolValue == false) {
      rtn.boolValue = false;
      rtn.stringValues.addAll(
        activitiesSync.stringValues,
      );
      return rtn;
    }

    // possible optimization: {{api_url}}/cases/1/surveys/1/responses
    // possible optimization: {{api_url}}/activities/1/surveys/1/responses
    // - surveys responses

    print('sync success');

    rtn.boolValue = true;
    return rtn;
  }
}
