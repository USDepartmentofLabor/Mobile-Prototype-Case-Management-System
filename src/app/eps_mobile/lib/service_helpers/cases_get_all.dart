import 'dart:convert';
import 'package:eps_mobile/models/case_file.dart';
import 'package:eps_mobile/models/case_note.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/queries/case_status_queries.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class CasesGetAll {
  EpsState epsState;

  CasesGetAll(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<
          Tuple2<bool,
              List<Tuple3<CaseInstance, List<CaseNote>, List<CaseFile>>>>>
      getAllCases(
    String serviceUrl,
    bool useHttps,
    int caseDefinitionId,
  ) async {
    Uri logInUri;

    String url = '/cases';

    Map<String, String> queryParameters = {};

    if (caseDefinitionId != null) {
      queryParameters = {
        'case_definition_id': caseDefinitionId.toString(),
      };
    }

    if (useHttps) {
      //logInUri = Uri.https(serviceUrl, url, queryParameters);
      logInUri = caseDefinitionId != null
          ? Uri.https(serviceUrl, url, queryParameters)
          : Uri.https(serviceUrl, url);
    } else {
      //logInUri = Uri.http(serviceUrl, url, queryParameters);
      logInUri = caseDefinitionId != null
          ? Uri.http(serviceUrl, url, queryParameters)
          : Uri.http(serviceUrl, url);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    final response = await http.get(logInUri, headers: headers);

    var returnData =
        new List<Tuple3<CaseInstance, List<CaseNote>, List<CaseFile>>>();

    if (response.statusCode == 200) {
      for (var caseData in json.decode(response.body)) {
        var caseInstance = new CaseInstance();
        if (caseData.containsKey('id')) {
          caseInstance.id = caseData['id'];
        }
        if (caseData.containsKey('key')) {
          caseInstance.key = caseData['key'];
        }
        if (caseData.containsKey('name')) {
          caseInstance.name = caseData['name'];
        }
        if (caseData.containsKey('description')) {
          caseInstance.description = caseData['description'];
        }
        if (caseData.containsKey('case_definition')) {
          caseInstance.caseDefinitionId = caseData['case_definition']['id'];
        }
        if (caseData.containsKey('created_at')) {
          caseInstance.createdAt = DateTime.parse(caseData['created_at']);
        }
        if (caseData.containsKey('updated_at')) {
          caseInstance.updatedAt = DateTime.parse(caseData['updated_at']);
        }

        // created_by
        var createdByKey = 'created_by';
        if (caseData.containsKey(createdByKey)) {
          var createdByData = caseData[createdByKey];
          var idKey = 'id';
          if (createdByData.containsKey(idKey)) {
            caseInstance.createdBy = createdByData[idKey];
          }
        }

        // updated_by
        var updatedByKey = 'updated_by';
        if (caseData.containsKey(updatedByKey)) {
          var updatedByData = caseData[updatedByKey];
          var idKey = 'id';
          if (updatedByData.containsKey(idKey)) {
            caseInstance.updatedBy = updatedByData[idKey];
          }
        }

        // assigned_to
        var assignedToKey = 'assigned_to';
        if (caseData.containsKey(assignedToKey)) {
          if (caseData[assignedToKey] != null) {
            var assignedToData = caseData[assignedToKey];
            var idKey = 'id';
            if (assignedToData.containsKey(idKey)) {
              caseInstance.assignedTo = assignedToData[idKey];
            }
          } else {
            caseInstance.assignedTo = -1;
          }
        }

        // case status
        if (caseData.containsKey('status')) {
          var caseStatusData = caseData['status'];
          if (caseStatusData.containsKey('id')) {
            var caseStatusId = caseStatusData['id'];
            // get the local case status id and make sure we have it
            var localCaseStatus = await CaseStatusQueries.getCaseStatusById(
              epsState.database.database,
              caseStatusId,
            );
            if (localCaseStatus != null) {
              caseInstance.caseStatusId = caseStatusId;
            } else {
              // error
            }
          }
        }

        // Custom Fields
        var customFieldsKey = 'custom_fields';
        if (caseData.containsKey(customFieldsKey)) {
          var data = caseData[customFieldsKey];
          Map<String, List> customFieldMap = {'data': []};
          var list = [];
          for (var customField in data) {
            //customFieldMap.addAll(customField);
            list.add(customField);
          }
          customFieldMap['data'] = list;
          caseInstance.customFieldData = jsonEncode(customFieldMap);
        }

        // case notes
        var caseNotes = new List<CaseNote>();
        if (caseData.containsKey('notes')) {
          var caseNotesData = caseData['notes'];
          for (var caseNoteData in caseNotesData) {
            var caseNote = new CaseNote();
            caseNote.caseId = caseInstance.id;
            if (caseNoteData.containsKey('id')) {
              caseNote.id = caseNoteData['id'];
            }
            if (caseNoteData.containsKey('note')) {
              caseNote.note = caseNoteData['note'];
            }
            if (caseNoteData.containsKey('created_at')) {
              caseNote.createdAt = DateTime.parse(caseNoteData['created_at']);
            }
            if (caseNoteData.containsKey('updated_at')) {
              caseNote.updatedAt = DateTime.parse(caseNoteData['updated_at']);
            }
            if (caseNoteData.containsKey('created_by')) {
              var createdByData = caseNoteData['created_by'];
              if (createdByData.containsKey('id')) {
                caseNote.createdBy = createdByData['id'];
              }
            }
            if (caseNoteData.containsKey('updated_by')) {
              var updatedByData = caseNoteData['updated_by'];
              if (updatedByData.containsKey('id')) {
                caseNote.updatedBy = updatedByData['id'];
              }
            }
            caseNotes.add(caseNote);
          }
        }

        // case files
        var caseFiles = new List<CaseFile>();
        if (caseData.containsKey('documents')) {
          var caseFilesData = caseData['documents'];
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

            // created_at
            if (caseFileData.containsKey('created_at')) {
              caseFile.createdAt = DateTime.parse(caseFileData['created_at']);
            }

            // created_by -> id
            caseFile.createdBy = 1;

            caseFiles.add(caseFile);
          }
        }

        returnData.add(new Tuple3<CaseInstance, List<CaseNote>, List<CaseFile>>(
          caseInstance,
          caseNotes,
          caseFiles,
        ));
      }
      return new Tuple2<bool,
              List<Tuple3<CaseInstance, List<CaseNote>, List<CaseFile>>>>(
          true, returnData);
    }

    // failure
    return Tuple2<bool,
            List<Tuple3<CaseInstance, List<CaseNote>, List<CaseFile>>>>(
        false, null);
  }
}
