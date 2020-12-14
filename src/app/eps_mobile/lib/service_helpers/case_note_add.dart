import 'dart:convert';
import 'dart:async';
import 'package:eps_mobile/queries/user_queries.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/case_note.dart';

class CaseNoteAdd {
  static Future<Tuple2<bool, CaseNote>> addCaseNote(
    EpsState epsState,
    CaseInstance caseInstance,
    CaseNote caseNote,
  ) async {
    Uri uri;

    var path = '/cases/' + caseInstance.id.toString() + '/notes';

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
      "case_id": caseInstance.id,
      "note": caseNote.note,
    };

    final response =
        await http.post(uri, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      // get properties back
      var caseNote = new CaseNote();

      // id
      var idKey = 'id';
      if (responseData.containsKey(idKey)) {
        caseNote.id = responseData[idKey];
      }

      // case id
      caseNote.caseId = caseInstance.id;

      var noteKey = 'note';
      if (responseData.containsKey(noteKey)) {
        caseNote.note = responseData[noteKey];
      }

      // created_at
      var createdAtKey = 'created_at';
      if (responseData.containsKey(createdAtKey)) {
        caseNote.createdAt = DateTime.parse(responseData[createdAtKey]);
      }

      // updated_at
      var updatedAtKey = 'updated_at';
      if (responseData.containsKey(updatedAtKey)) {
        caseNote.updatedAt = DateTime.parse(responseData[updatedAtKey]);
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
          caseNote.createdBy = userIdExists ? userId : -1;
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
          caseNote.updatedBy = userIdExists ? userId : -1;
        }
      }

      return Tuple2<bool, CaseNote>(
        true,
        caseNote,
      );
    }

    // failure
    return Tuple2<bool, CaseNote>(false, null);
  }
}
