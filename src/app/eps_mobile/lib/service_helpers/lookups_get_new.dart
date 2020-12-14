import 'dart:convert';
import 'package:eps_mobile/models/case_status.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/permission.dart';
import 'package:eps_mobile/models/survey_response_status.dart';
import 'package:eps_mobile/models/user_role.dart';
import 'package:http/http.dart' as http;

class LookupsGetReturn {
  bool success;
  List<String> errors;
  List<CaseStatus> caseStatuses;
  List<Permission> permissions;
  List<SurveyResponseStatus> surveyResponseStatuses;
  List<UserRole> userRoles;

  LookupsGetReturn() {
    this.success = false;
    this.errors = List<String>();
    this.caseStatuses = List<CaseStatus>();
    this.permissions = List<Permission>();
    this.surveyResponseStatuses = List<SurveyResponseStatus>();
    this.userRoles = List<UserRole>();
  }
}

class LookupsGetNew {
  static String getName() {
    return 'LookupsGet';
  }

  static String getPath() {
    return 'lib/service_calls/default/LookupsGet.dart';
  }

  static Future<LookupsGetReturn> getAll(
    EpsState epsState,
  ) async {
    var rtn = LookupsGetReturn();

    Uri uri;

    String apiPath = '/lookups';

    if (epsState.serviceInfo.useHttps) {
      uri = Uri.https(epsState.serviceInfo.url, apiPath);
    } else {
      uri = Uri.http(epsState.serviceInfo.url, apiPath);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken,
    };

    http.Response response;

    response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      // case status
      var caseStatuses = new List<CaseStatus>();
      if (responseData.containsKey('case_statuses')) {
        var caseStatusesData = responseData['case_statuses'];
        for (var caseStatusObject in caseStatusesData) {
          var caseStatus = new CaseStatus();
          if (caseStatusObject.containsKey('default')) {
            caseStatus.isDefault = caseStatusObject['default'];
          }
          if (caseStatusObject.containsKey('id')) {
            caseStatus.id = caseStatusObject['id'];
          }
          if (caseStatusObject.containsKey('name')) {
            caseStatus.name = caseStatusObject['name'];
          }
          if (caseStatusObject.containsKey('is_final')) {
            caseStatus.isFinal = caseStatusObject['is_final'];
          }
          if (caseStatusObject.containsKey('color')) {
            caseStatus.color = caseStatusObject['color'];
          }
          caseStatuses.add(caseStatus);
        }
        rtn.caseStatuses = caseStatuses;
      }

      // permissions
      var permissions = List<Permission>();
      var permissionsKey = 'permissions';
      if (responseData.containsKey(permissionsKey)) {
        var permissionsData = responseData[permissionsKey];
        for (var permissionData in permissionsData) {
          var permission = Permission();

          var codeKey = 'code';
          if (permissionData.containsKey(codeKey)) {
            permission.code = permissionData[codeKey];
          }

          var nameKey = 'name';
          if (permissionData.containsKey(nameKey)) {
            permission.name = permissionData[nameKey];
          }

          var valueKey = 'value';
          if (permissionData.containsKey(valueKey)) {
            permission.value = permissionData[valueKey];
          }

          permissions.add(permission);
        }
        rtn.permissions = permissions;
      }

      // Survey Response Statuses
      var surveyResponseStatuses = new List<SurveyResponseStatus>();
      if (responseData.containsKey('survey_response_statuses')) {
        var surveyResponseStatusesData =
            responseData['survey_response_statuses'];
        for (var surveyResponseStatusObject in surveyResponseStatusesData) {
          var surveyResponseStatus = new SurveyResponseStatus();
          if (surveyResponseStatusObject.containsKey('default')) {
            surveyResponseStatus.isDefault =
                surveyResponseStatusObject['default'];
          }
          if (surveyResponseStatusObject.containsKey('id')) {
            surveyResponseStatus.id = surveyResponseStatusObject['id'];
          }
          if (surveyResponseStatusObject.containsKey('name')) {
            surveyResponseStatus.name = surveyResponseStatusObject['name'];
          }
          surveyResponseStatuses.add(surveyResponseStatus);
        }
        rtn.surveyResponseStatuses = surveyResponseStatuses;
      }

      // User Roles
      var rolesKey = 'roles';
      var userRoles = new List<UserRole>();
      if (responseData.containsKey(rolesKey)) {
        var rolesData = responseData[rolesKey];
        for (var roleData in rolesData) {
          var userRole = new UserRole();
          if (roleData.containsKey('default')) {
            userRole.isDefault = roleData['default'];
          }
          if (roleData.containsKey('id')) {
            userRole.id = roleData['id'];
          }
          if (roleData.containsKey('name')) {
            userRole.name = roleData['name'];
          }
          if (roleData.containsKey('roleData')) {
            userRole.permissions = roleData['roleData'];
          }
          userRoles.add(userRole);
        }
        rtn.userRoles = userRoles;
      }

      rtn.success = true;
      return rtn;
    } else {
      rtn.errors.add(
        'error in ' + LookupsGetNew.getName() + ' - ' + LookupsGetNew.getPath(),
      );
      rtn.errors.add(
        'Status Code: ' + response.statusCode.toString(),
      );
      rtn.errors.add(
        'Message: ' + response.body,
      );
    }

    return rtn;
  }
}
