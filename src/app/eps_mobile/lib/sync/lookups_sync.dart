import 'package:eps_mobile/models/bool_list_string_tuple.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/queries/case_status_queries.dart';
import 'package:eps_mobile/queries/permission_queries.dart';
import 'package:eps_mobile/queries/survey_response_status_queries.dart';
import 'package:eps_mobile/queries/user_role_queries.dart';
import 'package:eps_mobile/service_helpers/lookups_get_new.dart';

class LookupsSync {
  static Future<BoolListStringTuple> fullSync(
    EpsState epsState,
  ) async {
    // simple sync
    // i.e. no changes from the app
    // server is the only source of truth

    var rtn = BoolListStringTuple();

    // get all from server
    var serverData = await LookupsGetNew.getAll(
      epsState,
    );

    if (serverData.success) {
      // ** case statuses

      // get all locals
      var existingLocalCaseStatus = await CaseStatusQueries.getAllCaseStatuses(
        epsState.database.database,
      );

      // server adds/updates
      var serverIdsCaseStatus = List<int>();
      for (var caseStatus in serverData.caseStatuses) {
        serverIdsCaseStatus.add(caseStatus.id);
        CaseStatusQueries.insertCaseStatus(
          epsState.database.database,
          caseStatus,
        );
      }

      // delete locals not on server
      for (var localCaseStatus in existingLocalCaseStatus) {
        if (!serverIdsCaseStatus.contains(localCaseStatus.id)) {
          CaseStatusQueries.deleteCaseStatus(
            epsState.database.database,
            localCaseStatus.id,
          );
        }
      }

      // *** permissions
      var existingLocalPermissions = await PermissionQueries.getAll(
        epsState.database.database,
      );

      // server adds/updates
      var serverIdsPermissions = List<int>();
      for (var permission in serverData.permissions) {
        serverIdsPermissions.add(permission.value);
        PermissionQueries.insertPermission(
          epsState.database.database,
          permission,
        );
      }

      // delete locals not on server
      for (var localPermission in existingLocalPermissions) {
        if (!serverIdsPermissions.contains(localPermission.value)) {
          PermissionQueries.deletePermission(
            epsState.database.database,
            localPermission.value,
          );
        }
      }

      // *** survey response statuses

      var existingLocalSurveyResponseStatuses =
          await SurveyResponseStatusQueries.getAll(
        epsState.database.database,
      );

      // server adds/updates
      var serverIdsSurveyResponseStatuses = List<int>();
      for (var obj in serverData.surveyResponseStatuses) {
        serverIdsSurveyResponseStatuses.add(obj.id);
        SurveyResponseStatusQueries.insertSurveyResponseStatus(
          epsState.database.database,
          obj,
        );
      }

      // delete locals not on server
      for (var localSurveyResponseStatus
          in existingLocalSurveyResponseStatuses) {
        if (!serverIdsSurveyResponseStatuses
            .contains(localSurveyResponseStatus.id)) {
          SurveyResponseStatusQueries.deleteSurveyResponseStatus(
            epsState.database.database,
            localSurveyResponseStatus.id,
          );
        }
      }

      // *** user roles
      var existingLocalUserRoles = await UserRoleQueries.getAllUserRoles(
        epsState.database.database,
      );

      // server adds/updates
      var serverIdsUserRoles = List<int>();
      for (var obj in serverData.userRoles) {
        serverIdsUserRoles.add(obj.id);
        UserRoleQueries.insertUserRole(
          epsState.database.database,
          obj,
        );
      }

      // delete locals not on server
      for (var localUserRole in existingLocalUserRoles) {
        if (!serverIdsUserRoles.contains(localUserRole.id)) {
          UserRoleQueries.deleteUserRole(
            epsState.database.database,
            localUserRole.id,
          );
        }
      }

      rtn.boolValue = true;
    } else {
      rtn.stringValues.addAll(
        serverData.errors,
      );
    }

    return rtn;
  }
}
