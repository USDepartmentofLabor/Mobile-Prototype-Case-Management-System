import 'package:eps_mobile/models/bool_list_string_tuple.dart';
import 'package:eps_mobile/models/case_note.dart';
import 'package:tuple/tuple.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CaseNotesGetByCaseId {
  static Future<Tuple2<BoolListStringTuple, List<CaseNote>>> getByCaseId(
    String jwtToken,
    String serviceUrl,
    bool useHttps,
    int caseId,
  ) async {
    Uri logInUri;

    String url = '/cases/' + caseId.toString() + '/notes';

    if (useHttps) {
      logInUri = Uri.https(serviceUrl, url);
    } else {
      logInUri = Uri.http(serviceUrl, url);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + jwtToken
    };

    final response = await http.get(logInUri, headers: headers);
    if (response.statusCode == 200) {
      var objects = List<CaseNote>();

      for (var objectData in json.decode(response.body)) {
        var object = CaseNote();

        // id
        var idKey = 'id';
        if (objectData.containsKey(idKey)) {
          object.id = objectData[idKey];
        }

        // case id
        // should check that "model_name": "Case",
        if (objectData.containsKey('model_id')) {
          object.caseId = objectData['model_id'];
        }

        // note
        if (objectData.containsKey('note')) {
          object.note = objectData['note'];
        }

        // createdAt
        var createdAtKey = 'created_at';
        if (objectData.containsKey(createdAtKey)) {
          object.createdAt = DateTime.parse(objectData[createdAtKey]);
        }

        // createdBy
        var createdByKey = 'created_by';
        if (objectData.containsKey(createdByKey)) {
          var createdByIdKey = 'id';
          if (objectData[createdByKey].containsKey(createdByIdKey)) {
            object.createdBy = objectData[createdByKey][createdByIdKey];
          }
        }

        // updatedAt
        var updatedAtKey = 'updated_at';
        if (objectData.containsKey(updatedAtKey)) {
          object.updatedAt = DateTime.parse(objectData[updatedAtKey]);
        }

        // updatedBy
        var updatedByKey = 'updated_by';
        if (objectData.containsKey(updatedByKey)) {
          var updatedByIdKey = 'id';
          if (objectData[updatedByKey].containsKey(updatedByIdKey)) {
            object.updatedBy = objectData[updatedByKey][updatedByIdKey];
          }
        }

        objects.add(object);
      }

      var boolRtn = BoolListStringTuple();
      boolRtn.boolValue = true;
      var rtn = Tuple2<BoolListStringTuple, List<CaseNote>>(
        boolRtn,
        objects,
      );
      return rtn;
    }

    // rtn false with errors
    var boolRtn = BoolListStringTuple();
    boolRtn.boolValue = false;
    boolRtn.stringValues.add('error in get case notes');
    var rtn = Tuple2<BoolListStringTuple, List<CaseNote>>(
      boolRtn,
      null,
    );
    return rtn;
  }
}
