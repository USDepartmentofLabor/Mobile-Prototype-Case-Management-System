import 'dart:convert';
import 'dart:async';
import 'package:eps_mobile/models/activity.dart';
import 'package:eps_mobile/service_helpers/activity_custom_field_put.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';

class ActivityAdd {
  static Future<Tuple2<bool, Activity>> add(
    String serviceUrl,
    bool useHttps,
    EpsState epsState,
    int caseInstanceId,
    int activityDefinitionId,
    Activity activity,
  ) async {
    Uri uri;

    var path = '/activities';

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

    body['activity_definition_id'] = activityDefinitionId;
    body['case_id'] = caseInstanceId;

    body['name'] = activity.name;
    body['description'] = activity.description;

    // notes
    body['notes'] = [];

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      // get properties back

      // id
      if (responseData.containsKey('id')) {
        activity.id = responseData['id'];
      }

      if (responseData.containsKey('custom_fields')) {
        var customFieldData = [];
        customFieldData = responseData['custom_fields'];
        for (var field in customFieldData) {
          var idToUpdate = field['activity_definition_custom_field_id'];
          var value = '';

          // find the new value
          for (var localCustom
              in json.decode(activity.customFieldData)['data']) {
            if (localCustom['id'] == idToUpdate) {
              value = json.encode(localCustom['value']);
            }
          }

          var success = await ActivityCustomFieldPut.put(
            epsState,
            activity.id,
            field['id'],
            value,
          );
          if (!success) {
            return Tuple2<bool, Activity>(false, null);
          }
        }
      }

      return Tuple2<bool, Activity>(true, activity);
    }

    // failure
    return Tuple2<bool, Activity>(false, null);
  }
}
