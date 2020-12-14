import 'package:eps_mobile/models/activity.dart';
import 'package:eps_mobile/models/activity_file.dart';
import 'package:eps_mobile/models/activity_note.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActivityGetById {
  static Future<
      Tuple5<bool, List<String>, Activity, List<ActivityNote>,
          List<ActivityFile>>> getById(
    EpsState epsState,
    int activityId,
  ) async {
    var errors = List<String>();

    Uri logInUri;

    String url = '/activities/' + activityId.toString();

    if (epsState.serviceInfo.useHttps) {
      logInUri = Uri.https(epsState.serviceInfo.url, url);
    } else {
      logInUri = Uri.http(epsState.serviceInfo.url, url);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken,
    };

    final response = await http.get(logInUri, headers: headers);

    if (response.statusCode == 200) {
      var actData = json.decode(response.body);
      var activity = new Activity();

      var idKey = 'id';
      if (actData.containsKey(idKey)) {
        activity.id = actData[idKey];
      }

      var actFiles = new List<ActivityFile>();

      var documentsKey = 'documents';
      if (actData.containsKey(documentsKey)) {
        var caseFilesData = actData[documentsKey];
        for (var caseFileData in caseFilesData) {
          var caseFile = ActivityFile();

          if (caseFileData.containsKey('id')) {
            caseFile.id = caseFileData['id'];
          }

          caseFile.activityId = activity.id;

          if (caseFileData.containsKey('document_id')) {
            caseFile.documentId = caseFileData['document_id'];
          }

          if (caseFileData.containsKey('original_filename')) {
            caseFile.originalFileName = caseFileData['original_filename'];
          }

          if (caseFileData.containsKey('remote_filename')) {
            caseFile.remoteFileName = caseFileData['remote_filename'];
          }

          if (caseFileData.containsKey('created_at')) {
            caseFile.createdAt = DateTime.parse(caseFileData['created_at']);
          }

          if (caseFileData.containsKey('created_by')) {
            var createdByData = caseFileData['created_by'];
            if (createdByData.containsKey('id')) {
              caseFile.createdBy = createdByData['id'];
            }
          }

          if (caseFile.id != null) {
            actFiles.add(caseFile);
          }
        }
      }

      return Tuple5<bool, List<String>, Activity, List<ActivityNote>,
          List<ActivityFile>>(
        true,
        errors,
        activity,
        null,
        actFiles,
      );
    } else {
      // get the error code and string
      print(response.bodyBytes.toString());
      errors.add(
        response.statusCode.toString(),
      );
      errors.add(
        response.body,
      );
    }

    return Tuple5<bool, List<String>, Activity, List<ActivityNote>,
        List<ActivityFile>>(
      false,
      errors,
      null,
      null,
      null,
    );
  }
}
