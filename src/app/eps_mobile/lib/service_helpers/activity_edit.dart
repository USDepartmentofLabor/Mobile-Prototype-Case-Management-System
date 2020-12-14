import 'dart:convert';
import 'dart:async';
import 'package:eps_mobile/service_helpers/activity_custom_field_put.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/activity.dart';
import 'package:eps_mobile/models/activity_definition.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:tuple/tuple.dart';

class ActivityEdit {
  static Future<Tuple2<bool, Activity>> add(
    String serviceUrl,
    bool useHttps,
    EpsState epsState,
    CaseInstance caseInstance,
    ActivityDefinition activityDefinition,
    Activity activity,
  ) async {
    Uri uri;

    var path = '/activities/' + activity.id.toString();

    if (useHttps) {
      uri = Uri.https(serviceUrl, path);
    } else {
      uri = Uri.http(serviceUrl, path);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    var body = {};

    body['name'] = activity.name;
    body['description'] = activity.description;

    // notes
    body['notes'] = [];

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // update custom fields
      for (var field in json.decode(activity.customFieldData)['data']) {
        ActivityCustomFieldPut.put(
          epsState,
          activity.id,
          field['id'],
          json.encode(field['value']),
        );
      }

      // return
      return Tuple2<bool, Activity>(true, activity);
    }

    // failure
    return Tuple2<bool, Activity>(false, null);
  }
}
