import 'dart:convert';
import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/project.dart';

class ProjectGet {
  static Future<Tuple2<bool, Project>> getProject(
    EpsState epsState,
  ) async {
    Uri uri;

    var path = '/project';

    if (epsState.serviceInfo.useHttps) {
      uri = Uri.https(epsState.serviceInfo.url, path);
    } else {
      uri = Uri.http(epsState.serviceInfo.url, path);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      var projectData = json.decode(response.body);

      var project = Project();

      var idKey = 'id';
      if (projectData.containsKey(idKey)) {
        project.id = projectData[idKey];
      }

      var agreementNumberKey = 'agreement_number';
      if (projectData.containsKey(agreementNumberKey)) {
        project.agreementNumber = projectData[agreementNumberKey];
      }

      var nameKey = 'name';
      if (projectData.containsKey(nameKey)) {
        project.name = projectData[nameKey];
      }

      var titleKey = 'title';
      if (projectData.containsKey(titleKey)) {
        project.title = projectData[titleKey];
      }

      var locationKey = 'location';
      if (projectData.containsKey(locationKey)) {
        project.location = projectData[locationKey];
      }

      var organizationKey = 'organization';
      if (projectData.containsKey(organizationKey)) {
        project.organization = projectData[organizationKey];
      }

      var fundingAmountKey = 'funding_amount';
      if (projectData.containsKey(fundingAmountKey)) {
        project.fundingAmount = projectData[fundingAmountKey];
      }

      var startDateKey = 'start_date';
      if (projectData.containsKey(startDateKey)) {
        project.startDate = DateTime.parse(projectData[startDateKey]);
      }

      var endDateKey = 'end_date';
      if (projectData.containsKey(endDateKey)) {
        project.endDate = DateTime.parse(projectData[endDateKey]);
      }

      var createdAtKey = 'created_at';
      if (projectData.containsKey(createdAtKey)) {
        project.createdAt = DateTime.parse(projectData[createdAtKey]);
      }

      var updatedAtKey = 'updated_at';
      if (projectData.containsKey(updatedAtKey)) {
        project.updatedAt = DateTime.parse(projectData[updatedAtKey]);
      }

      var createdByKey = 'created_by';
      if (projectData.containsKey(createdByKey)) {
        var projectCreatedByData = projectData[createdByKey];
        var createdByIdKey = 'id';
        if (projectCreatedByData.containsKey(createdByIdKey)) {
          project.createdBy = projectCreatedByData[createdByIdKey];
        }
      }

      var updatedByKey = 'updated_by';
      if (projectData.containsKey(updatedByKey)) {
        var projectUpdatedByData = projectData[updatedByKey];
        var updatedByIdKey = 'id';
        if (projectUpdatedByData.containsKey(updatedByIdKey)) {
          project.updatedBy = projectUpdatedByData[updatedByIdKey];
        }
      }

      return Tuple2<bool, Project>(
        true,
        project,
      );
    }

    // failure
    return Tuple2<bool, Project>(
      false,
      null,
    );
  }
}
