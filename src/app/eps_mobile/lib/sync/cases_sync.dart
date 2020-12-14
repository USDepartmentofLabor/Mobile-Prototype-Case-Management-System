import 'package:eps_mobile/models/bool_list_string_tuple.dart';
import 'package:eps_mobile/models/case_file.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/case_note.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/queries/case_file_queries.dart';
import 'package:eps_mobile/queries/case_note_queries.dart';
import 'package:eps_mobile/queries/case_queries.dart';
import 'package:eps_mobile/service_helpers/case_add.dart';
import 'package:eps_mobile/service_helpers/case_edit.dart';
import 'package:eps_mobile/service_helpers/case_get_by_id.dart';
import 'package:eps_mobile/service_helpers/case_note_add.dart';
import 'package:eps_mobile/service_helpers/case_notes_get_by_case_id.dart';
import 'package:eps_mobile/service_helpers/cases_get_all.dart';
import 'package:eps_mobile/service_helpers/upload_document.dart';

class CasesSync {
  static Future<BoolListStringTuple> fullSync(
    EpsState epsState,
  ) async {
    // "regular sync"
    // i.e.
    // server has new
    // server has changes
    // server has deletes
    //
    // local has new
    // local has changes

    var rtn = BoolListStringTuple();

    // get all cases
    var serverCases = await CasesGetAll(epsState).getAllCases(
      epsState.serviceInfo.url,
      epsState.serviceInfo.useHttps,
      null,
    );

    var serverIds = List<int>();

    if (serverCases.item1 == true) {
      for (var serverCase in serverCases.item2) {
        serverIds.add(serverCase.item1.id);

        // compare to local
        var query = await CaseQueries.getCaseByIdServer(
          epsState.database.database,
          serverCase.item1.id,
        );
        if (query != null) {
          // match - compare
          if (serverCase.item1.updatedAt.microsecondsSinceEpoch >=
              query.updatedAt.microsecondsSinceEpoch) {
            // server wins - replace local
            CaseQueries.insertCase(
              epsState.database.database,
              serverCase.item1,
            );
          } else {
            // local wins - send to server
            var sendResult = await CaseEdit(epsState).editCase(
              epsState.serviceInfo.url,
              epsState.serviceInfo.useHttps,
              query,
            );
            if (sendResult.item1 == false) {
              // error
              rtn.boolValue = false;
              rtn.stringValues.add('error updating case instance to server');
              return rtn;
            }
          }
        } else {
          // new from server - add it here
          await CaseQueries.insertCase(
            epsState.database.database,
            serverCase.item1,
          );
        }
      }
    } else {
      // error
      rtn.boolValue = false;
      rtn.stringValues.add('error getting cases');
      return rtn;
    }

    // add new local
    var localLocalResponses = await CaseQueries.getAllCasesLocal(
      epsState.database.database,
    );
    for (var localResponse in localLocalResponses) {
      var localId = localResponse.id;
      localResponse.id = null;

      var sendResult = await CaseAdd(epsState).addCase(
        epsState.serviceInfo.url,
        epsState.serviceInfo.useHttps,
        localResponse,
      );
      if (sendResult.item1 == false) {
        // error
        rtn.boolValue = false;
        rtn.stringValues.add('error adding local case to server');
        return rtn;
      } else {
        // remove the local value
        await CaseQueries.deleteCaseLocal(
          epsState.database.database,
          localId,
        );

        // add it to server
        await CaseQueries.insertCase(
          epsState.database.database,
          sendResult.item2,
        );
        serverIds.add(sendResult.item2.id);
      }
    }

    // delete locals in server table not in server data
    // get locals
    var localCases = await CaseQueries.getAllCasesServer(
      epsState.database.database,
    );
    for (var local in localCases) {
      if (!serverIds.contains(local.id)) {
        await CaseQueries.deleteCase(
          epsState.database.database,
          local.id,
        );
      }
    }

    // case notes
    var casesPostSync = await CaseQueries.getAllCasesServer(
      epsState.database.database,
    );
    for (var serverCaseNow in casesPostSync) {
      // get case notes from server by case
      var notes = await CaseNotesGetByCaseId.getByCaseId(
        epsState.user.jwtToken,
        epsState.serviceInfo.url,
        epsState.serviceInfo.useHttps,
        serverCaseNow.id,
      );

      if (notes.item1.boolValue == true) {
        var caseNoteSync = await syncCaseNotesByCase(
          epsState,
          serverCaseNow,
          notes.item2,
        );

        if (caseNoteSync.boolValue == false) {
          rtn.stringValues.add('error syncing case notes');
          return rtn;
        }
      } else {
        rtn.stringValues.add('error getting case notes');
        return rtn;
      }
    }

    // case files
    for (var serverCaseNow in casesPostSync) {
      // get files from server
      var serverCase = await CaseGetById.getById(
        epsState,
        serverCaseNow.id,
      );

      if (serverCase.item1 == false) {
        rtn.stringValues.add('error getting case');
        return rtn;
      } else {
        var caseFileSync = await syncCaseFilesByCase(
          epsState,
          serverCaseNow,
          serverCase.item5,
        );

        if (caseFileSync.boolValue == false) {
          rtn.stringValues.add('error adding case file');
          return rtn;
        }
      }
    }

    rtn.boolValue = true;
    return rtn;
  }

  static Future<BoolListStringTuple> syncCaseNotesByCase(
    EpsState epsState,
    CaseInstance caseInstance,
    List<CaseNote> caseNotes,
  ) async {
    // "regular sync"
    // but case notes are not eidtable
    // so add new from server
    // post new from local

    var rtn = BoolListStringTuple();

    var serverIds = List<int>();

    for (var serverCaseNote in caseNotes) {
      await CaseNoteQueries.insertCaseNote(
        epsState.database.database,
        serverCaseNote,
      );
      serverIds.add(serverCaseNote.id);
    }

    // add new local
    var localQuery = await CaseNoteQueries.getLocalCaseNotesByCase(
      epsState.database.database,
      caseInstance,
    );
    for (var localCaseNote in localQuery) {
      var localId = localCaseNote.id;
      localCaseNote.id = null;

      var sendResult = await CaseNoteAdd.addCaseNote(
        epsState,
        caseInstance,
        localCaseNote,
      );
      if (sendResult.item1 == false) {
        // error
        rtn.boolValue = false;
        rtn.stringValues.add('error adding local case note to server');
        return rtn;
      } else {
        // remove the local value
        await CaseNoteQueries.deleteCaseNoteLocal(
          epsState.database.database,
          localId,
        );

        // add it to server
        await CaseNoteQueries.insertCaseNote(
          epsState.database.database,
          sendResult.item2,
        );
        serverIds.add(sendResult.item2.id);
      }
    }

    // delete locals in server table not in server data
    // get locals
    var localCases = await CaseNoteQueries.getCaseNotesByCase(
      epsState.database.database,
      caseInstance,
    );
    for (var local in localCases) {
      if (!serverIds.contains(local.id)) {
        await CaseNoteQueries.deleteCaseNote(
          epsState.database.database,
          local.id,
        );
      }
    }

    rtn.boolValue = true;
    return rtn;
  }

  static Future<BoolListStringTuple> syncCaseFilesByCase(
    EpsState epsState,
    CaseInstance caseInstance,
    List<CaseFile> caseFiles,
  ) async {
    // "regular sync"
    // but case files are not eidtable
    // so add new from server
    // post new from local

    var rtn = BoolListStringTuple();

    var serverIds = List<int>();

    for (var serverCaseNote in caseFiles) {
      await CaseFileQueries.insertCaseFile(
        epsState.database.database,
        serverCaseNote,
      );
      serverIds.add(serverCaseNote.id);
    }

    // add new local
    var localQuery = await CaseFileQueries.getLocalCaseFilesByCase(
      epsState.database.database,
      caseInstance,
    );
    for (var localCaseNote in localQuery) {
      var sendResult = await UploadDocument.uploadDocumentAsync(
        epsState,
        caseInstance,
        null,
        null,
      );
      if (sendResult.item1 == false) {
        // error
        rtn.boolValue = false;
        rtn.stringValues.add('error adding local case note to server');
        return rtn;
      } else {
        // remove the local value
        await CaseFileQueries.deleteLocal(
          epsState.database.database,
          localCaseNote.id,
        );

        // add it to server
        await CaseFileQueries.insertCaseFile(
          epsState.database.database,
          sendResult.item2,
        );
        serverIds.add(sendResult.item2.id);
      }
    }

    // delete locals in server table not in server data
    // get locals
    var localCases = await CaseFileQueries.getCaseFilesByCase(
      epsState.database.database,
      caseInstance,
    );
    for (var local in localCases) {
      if (!serverIds.contains(local.id)) {
        await CaseFileQueries.delete(
          epsState.database.database,
          local.id,
        );
      }
    }

    rtn.boolValue = true;
    return rtn;

    //
  }
}
