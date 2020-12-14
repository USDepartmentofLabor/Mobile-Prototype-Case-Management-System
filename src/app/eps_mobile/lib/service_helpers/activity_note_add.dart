import 'dart:convert';
import 'dart:async';
import 'package:eps_mobile/models/activity_note.dart';
import 'package:eps_mobile/queries/user_queries.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';

class ActivityNoteAdd {
  static Future<Tuple2<bool, ActivityNote>> add(
    EpsState epsState,
    int activityId,
    ActivityNote activityNote,
  ) async {
    Uri uri;

    var path = '/activities/' + activityId.toString() + '/notes';

    if (epsState.serviceInfo.useHttps) {
      uri = Uri.https(epsState.serviceInfo.url, path);
    } else {
      uri = Uri.http(epsState.serviceInfo.url, path);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    var body = {
      "activity_id": activityId,
      "note": activityNote.note,
    };

    final response =
        await http.post(uri, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      // get properties back
      var note = new ActivityNote();

      // id
      var idKey = 'id';
      if (responseData.containsKey(idKey)) {
        note.id = responseData[idKey];
      }

      // case id
      note.activityId = activityId;

      var noteKey = 'note';
      if (responseData.containsKey(noteKey)) {
        note.note = responseData[noteKey];
      }

      // created_at
      var createdAtKey = 'created_at';
      if (responseData.containsKey(createdAtKey)) {
        note.createdAt = DateTime.parse(responseData[createdAtKey]);
      }

      // updated_at
      var updatedAtKey = 'updated_at';
      if (responseData.containsKey(updatedAtKey)) {
        note.updatedAt = DateTime.parse(responseData[updatedAtKey]);
      }

      // createdBy
      var createdByKey = 'created_by';
      if (responseData.containsKey(createdByKey)) {
        var createdByData = responseData[createdByKey];
        var createdByIdKey = 'id';
        if (createdByData.containsKey(createdByIdKey)) {
          var userId = createdByData[createdByIdKey];
          var userIdExists = await UserQueries.getUserIdExists(
            epsState.database.database,
            userId,
          );
          note.createdBy = userIdExists ? userId : -1;
        }
      }

      // updatedBy
      var updatedByKey = 'updated_by';
      if (responseData.containsKey(updatedByKey)) {
        var updatedByData = responseData[updatedByKey];
        var updatedByIdKey = 'id';
        if (updatedByData.containsKey(updatedByIdKey)) {
          var userId = updatedByData[updatedByIdKey];
          var userIdExists = await UserQueries.getUserIdExists(
            epsState.database.database,
            userId,
          );
          note.updatedBy = userIdExists ? userId : -1;
        }
      }

      return Tuple2<bool, ActivityNote>(
        true,
        note,
      );
    }

    // failure
    return Tuple2<bool, ActivityNote>(false, null);
  }
}
