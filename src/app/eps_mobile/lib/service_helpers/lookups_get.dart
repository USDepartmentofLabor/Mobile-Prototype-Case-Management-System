import 'dart:convert';
import 'package:eps_mobile/models/case_status.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/error_code.dart';
import 'package:eps_mobile/models/permission.dart';
import 'package:eps_mobile/models/survey_response_status.dart';
import 'package:eps_mobile/models/user_role.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class LookupsGet {
  EpsState epsState;

  LookupsGet(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<
      Tuple2<
          bool,
          Tuple4<List<CaseStatus>, List<Permission>, List<UserRole>,
              List<SurveyResponseStatus>>>> getLookups(
    String serviceUrl,
    bool useHttps,
  ) async {
    Uri uri;
    var url = '/lookups';

    if (useHttps) {
      uri = Uri.https(serviceUrl, url);
    } else {
      uri = Uri.http(serviceUrl, url);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      var caseStatuses = new List<CaseStatus>();
      var permissions = List<Permission>();
      var errorCodes = new List<ErrorCode>();
      var userRoles = new List<UserRole>();
      var surveyResponseStatuses = new List<SurveyResponseStatus>();

      // case status
      if (responseData.containsKey('case_statuses')) {
        var caseStatusesData = responseData['case_statuses'];
        for (var caseStatusObject in caseStatusesData) {
          var caseStatus = new CaseStatus();

          var isDefaultKey = 'default';
          if (caseStatusObject.containsKey(isDefaultKey)) {
            caseStatus.isDefault = caseStatusObject[isDefaultKey];
          }

          var idKey = 'id';
          if (caseStatusObject.containsKey(idKey)) {
            caseStatus.id = caseStatusObject[idKey];
          }

          var nameKey = 'name';
          if (caseStatusObject.containsKey(nameKey)) {
            caseStatus.name = caseStatusObject[nameKey];
          }

          var isFinalKey = 'is_final';
          if (caseStatusObject.containsKey(isFinalKey)) {
            caseStatus.isFinal = caseStatusObject[isFinalKey];
          }

          var colorKey = 'color';
          if (caseStatusObject.containsKey(colorKey)) {
            caseStatus.color = caseStatusObject[colorKey];
          }

          caseStatuses.add(caseStatus);
        }
      }

      // permissions
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
      }

      // error codes
      if (responseData.containsKey('error_codes')) {
        var errorCodeData = responseData['error_codes'];
        for (var errorCodeObject in errorCodeData) {
          var errorCode = new ErrorCode();
          if (errorCodeObject.containsKey('code')) {
            errorCode.code = errorCodeObject['code'];
          }
          if (errorCodeObject.containsKey('message')) {
            errorCode.message = errorCodeObject['message'];
          }
          if (errorCodeObject.containsKey('name')) {
            errorCode.name = errorCodeObject['name'];
          }
          errorCodes.add(errorCode);
        }
      }

      // user roles
      if (responseData.containsKey('roles')) {
        var userRolesData = responseData['roles'];
        for (var userRoleObject in userRolesData) {
          var userRole = new UserRole();
          if (userRoleObject.containsKey('default')) {
            userRole.isDefault = userRoleObject['default'];
          }
          if (userRoleObject.containsKey('id')) {
            userRole.id = userRoleObject['id'];
          }
          if (userRoleObject.containsKey('name')) {
            userRole.name = userRoleObject['name'];
          }
          if (userRoleObject.containsKey('permissions')) {
            userRole.permissions = userRoleObject['permissions'];
          }
          userRoles.add(userRole);
        }
      }

      // Survey Response Statuses
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
      }

      return Tuple2<
              bool,
              Tuple4<List<CaseStatus>, List<Permission>, List<UserRole>,
                  List<SurveyResponseStatus>>>(
          true,
          Tuple4<List<CaseStatus>, List<Permission>, List<UserRole>,
                  List<SurveyResponseStatus>>(
              caseStatuses, permissions, userRoles, surveyResponseStatuses));
    }

    // failure
    return Tuple2<
        bool,
        Tuple4<List<CaseStatus>, List<Permission>, List<UserRole>,
            List<SurveyResponseStatus>>>(false, null);
  }
}
