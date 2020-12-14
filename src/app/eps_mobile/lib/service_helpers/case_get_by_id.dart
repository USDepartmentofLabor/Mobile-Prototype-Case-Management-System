import 'dart:convert';
import 'package:eps_mobile/models/case_file.dart';
import 'package:eps_mobile/models/case_note.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';
import 'package:eps_mobile/models/case_instance.dart';

class CaseGetById {
  static Future<
      Tuple5<bool, List<String>, CaseInstance, List<CaseNote>,
          List<CaseFile>>> getById(
    EpsState epsState,
    int caseId,
  ) async {
    var errors = List<String>();

    Uri logInUri;

    String url = '/cases/' + caseId.toString();

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
      var caseData = json.decode(response.body);
      var caseInstance = new CaseInstance();

      var idKey = 'id';
      if (caseData.containsKey(idKey)) {
        caseInstance.id = caseData[idKey];
      }

      var keyKey = 'key';
      if (caseData.containsKey(keyKey)) {
        caseInstance.key = caseData[keyKey];
      }

      var nameKey = 'name';
      if (caseData.containsKey(nameKey)) {
        caseInstance.name = caseData[nameKey];
      }

      var descriptionKey = 'description';
      if (caseData.containsKey(descriptionKey)) {
        caseInstance.description = caseData[descriptionKey];
      }

      var caseDefinitionKey = 'case_definition';
      if (caseData.containsKey(caseDefinitionKey)) {
        var caseDefinitionIdKey = 'id';
        var caseDefinitionData = caseData[caseDefinitionKey];
        if (caseDefinitionData.containsKey(caseDefinitionIdKey)) {
          caseInstance.caseDefinitionId =
              caseDefinitionData[caseDefinitionIdKey];
        }
      }

      var createdAtKey = 'created_at';
      if (caseData.containsKey(createdAtKey)) {
        caseInstance.createdAt = DateTime.parse(caseData[createdAtKey]);
      }

      var updatedAtKey = 'updated_at';
      if (caseData.containsKey(updatedAtKey)) {
        caseInstance.updatedAt = DateTime.parse(caseData[updatedAtKey]);
      }

      var createdByKey = 'created_by';
      if (caseData.containsKey(createdByKey)) {
        var createdByData = caseData[createdByKey];
        var createdByIdKey = 'id';
        if (createdByData.containsKey(createdByIdKey)) {
          caseInstance.createdBy = createdByData[createdByIdKey];
        }
      }

      // updated_by
      var updatedByKey = 'updated_by';
      if (caseData.containsKey(updatedByKey)) {
        var updatedByData = caseData[updatedByKey];
        var updatedByIdKey = 'id';
        if (updatedByData.containsKey(updatedByIdKey)) {
          caseInstance.updatedBy = updatedByData[updatedByIdKey];
        }
      }

      // assigned_to
      var assignedToKey = 'assigned_to';
      if (caseData.containsKey(assignedToKey)) {
        if (caseData[assignedToKey] != null) {
          var assignedToData = caseData[assignedToKey];
          var assignedToIdKey = 'id';
          if (assignedToData.containsKey(assignedToIdKey)) {
            caseInstance.assignedTo = assignedToData[assignedToIdKey];
          }
        } else {
          caseInstance.assignedTo = -1;
        }
      }

      // case status
      var caseStatusKey = 'status';
      if (caseData.containsKey(caseStatusKey)) {
        var caseStatusData = caseData[caseStatusKey];
        var caseStatusIdKey = 'id';
        if (caseStatusData.containsKey(caseStatusIdKey)) {
          caseInstance.caseStatusId = caseStatusData[caseStatusIdKey];
        }
      }

      // Custom Fields
      var customFieldsKey = 'custom_fields';
      if (caseData.containsKey(customFieldsKey)) {
        var data = caseData[customFieldsKey];
        Map<String, List> customFieldMap = {'data': []};
        var list = [];
        for (var customField in data) {
          list.add(customField);
        }
        customFieldMap['data'] = list;
        caseInstance.customFieldData = jsonEncode(customFieldMap);
      }

      var createdLocationKey = 'created_location';
      if (caseData.containsKey(createdLocationKey)) {
        var createdLocationData = caseData[createdLocationKey];

        var createdLocationAltitudeKey = 'altitude';
        if (createdLocationData.containsKey(createdLocationAltitudeKey)) {
          if (createdLocationData[createdLocationAltitudeKey] != null) {
            caseInstance.createdAltitude =
                createdLocationData[createdLocationAltitudeKey];
          }
        }
      }

      // case notes
      var caseNotes = new List<CaseNote>();
      var notesKey = 'notes';
      if (caseData.containsKey(notesKey)) {
        var caseNotesData = caseData[notesKey];
        for (var caseNoteData in caseNotesData) {
          var caseNote = new CaseNote();
          caseNote.caseId = caseInstance.id;

          var caseNoteIdKey = 'id';
          if (caseNoteData.containsKey(caseNoteIdKey)) {
            caseNote.id = caseNoteData[caseNoteIdKey];
          }

          var caseNoteNoteKey = 'note';
          if (caseNoteData.containsKey(caseNoteNoteKey)) {
            caseNote.note = caseNoteData[caseNoteNoteKey];
          }

          var caseNoteCreatedAtKey = 'created_at';
          if (caseNoteData.containsKey(caseNoteCreatedAtKey)) {
            caseNote.createdAt =
                DateTime.parse(caseNoteData[caseNoteCreatedAtKey]);
          }

          var caseNoteUpdatedAtKey = 'updated_at';
          if (caseNoteData.containsKey(caseNoteUpdatedAtKey)) {
            caseNote.updatedAt =
                DateTime.parse(caseNoteData[caseNoteUpdatedAtKey]);
          }

          var caseNoteCreatedByKey = 'created_by';
          if (caseNoteData.containsKey(caseNoteCreatedByKey)) {
            var createdByData = caseNoteData[caseNoteCreatedByKey];
            var caseNoteCreatedByIdKey = 'id';
            if (createdByData.containsKey(caseNoteCreatedByIdKey)) {
              caseNote.createdBy = createdByData[caseNoteCreatedByIdKey];
            }
          }

          var caseNoteUpdatedByKey = 'updated_by';
          if (caseNoteData.containsKey(caseNoteUpdatedByKey)) {
            var updatedByData = caseNoteData[caseNoteUpdatedByKey];
            var caseNoteUpdatedByIdKey = 'id';
            if (updatedByData.containsKey(caseNoteUpdatedByIdKey)) {
              caseNote.updatedBy = updatedByData[caseNoteUpdatedByIdKey];
            }
          }

          caseNotes.add(caseNote);
        }
      }

      var caseFiles = new List<CaseFile>();

      var documentsKey = 'documents';
      if (caseData.containsKey(documentsKey)) {
        var caseFilesData = caseData[documentsKey];
        for (var caseFileData in caseFilesData) {
          var caseFile = CaseFile();

          if (caseFileData.containsKey('id')) {
            caseFile.id = caseFileData['id'];
          }

          caseFile.caseId = caseInstance.id;

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
            caseFiles.add(caseFile);
          }
        }
      }

      return Tuple5<bool, List<String>, CaseInstance, List<CaseNote>,
          List<CaseFile>>(
        true,
        errors,
        caseInstance,
        caseNotes,
        caseFiles,
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

    return Tuple5<bool, List<String>, CaseInstance, List<CaseNote>,
        List<CaseFile>>(
      false,
      errors,
      null,
      null,
      null,
    );
  }
}
