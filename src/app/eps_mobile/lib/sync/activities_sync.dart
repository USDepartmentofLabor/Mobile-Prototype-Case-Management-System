import 'package:eps_mobile/models/activity.dart';
import 'package:eps_mobile/models/activity_file.dart';
import 'package:eps_mobile/models/activity_note.dart';
import 'package:eps_mobile/models/bool_list_string_tuple.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/queries/activity_file_queries.dart';
import 'package:eps_mobile/queries/activity_note_queries.dart';
import 'package:eps_mobile/queries/activity_queries.dart';
import 'package:eps_mobile/service_helpers/activity_add.dart';
import 'package:eps_mobile/service_helpers/activity_edit.dart';
import 'package:eps_mobile/service_helpers/activity_get_all.dart';
import 'package:eps_mobile/service_helpers/activity_get_by_id.dart';
import 'package:eps_mobile/service_helpers/activity_note_add.dart';
import 'package:eps_mobile/service_helpers/activity_notes_get_by_activity_id.dart';
import 'package:eps_mobile/service_helpers/upload_document.dart';

class ActivitiesSync {
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

    // get all activities
    var serverActs = await ActivityGetAll.getAll(
      epsState.user.jwtToken,
      epsState.serviceInfo.url,
      epsState.serviceInfo.useHttps,
    );

    var serverIds = List<int>();

    if (serverActs.item1 == true) {
      for (var serverAct in serverActs.item3) {
        serverIds.add(serverAct.item1.id);

        // compare to local
        var query = await ActivityQueries.getByIdServer(
          epsState.database.database,
          serverAct.item1.id,
        );
        if (query != null) {
          // match - compare
          if (serverAct.item1.updatedAt.microsecondsSinceEpoch >=
              query.updatedAt.microsecondsSinceEpoch) {
            // server wins - replace local
            ActivityQueries.insertActivity(
              epsState.database.database,
              serverAct.item1,
            );
          } else {
            // local wins - send to server
            var sendResult = await ActivityEdit.add(
              epsState.serviceInfo.url,
              epsState.serviceInfo.useHttps,
              epsState,
              null,
              null,
              query,
            );
            if (sendResult.item1 == false) {
              // error
              rtn.boolValue = false;
              rtn.stringValues.add('error updating activity to server');
              return rtn;
            }
          }
        } else {
          // new from server - add it here
          await ActivityQueries.insertActivity(
            epsState.database.database,
            serverAct.item1,
          );
        }
      }
    } else {
      // error
      rtn.boolValue = false;
      rtn.stringValues.add('error getting activities');
      return rtn;
    }

    // add new local
    var localLocalResponses = await ActivityQueries.getAllLocal(
      epsState.database.database,
    );
    for (var localResponse in localLocalResponses) {
      var sendResult = await ActivityAdd.add(
        epsState.serviceInfo.url,
        epsState.serviceInfo.useHttps,
        epsState,
        localResponse.caseId,
        localResponse.activityDefinitionId,
        localResponse,
      );
      if (sendResult.item1 == false) {
        // error
        rtn.boolValue = false;
        rtn.stringValues.add('error adding local activity to server');
        return rtn;
      } else {
        // remove the local value
        await ActivityQueries.deleteLocal(
          epsState.database.database,
          localResponse.id,
        );

        // add it to server
        await ActivityQueries.insertActivity(
          epsState.database.database,
          sendResult.item2,
        );
        serverIds.add(sendResult.item2.id);
      }
    }

    // delete locals in server table not in server data
    // get locals
    var localActs = await ActivityQueries.getAllActivitys(
      epsState.database.database,
    );
    for (var local in localActs) {
      if (!serverIds.contains(local.id)) {
        await ActivityQueries.delete(
          epsState.database.database,
          local.id,
        );
      }
    }

    // notes

    // files

    // act notes
    var actsPostSync = await ActivityQueries.getAllActivitys(
      epsState.database.database,
    );
    for (var serverActNow in actsPostSync) {
      // get activity notes from server by activity
      var notes = await ActivityNotesGetByActivityId.getByActivityId(
        epsState.user.jwtToken,
        epsState.serviceInfo.url,
        epsState.serviceInfo.useHttps,
        serverActNow.id,
      );

      if (notes.item1.boolValue == true) {
        var actNoteSync = await syncActivityNotesByAct(
          epsState,
          serverActNow,
          notes.item2,
        );

        if (actNoteSync.boolValue == false) {
          rtn.stringValues.add('error syncing activity notes');
          return rtn;
        }
      } else {
        rtn.stringValues.add('error getting activitys notes');
        return rtn;
      }
    }

    // act files
    for (var serverActNow in actsPostSync) {
      // get files from server
      var serverAct = await ActivityGetById.getById(
        epsState,
        serverActNow.id,
      );

      if (serverAct.item1 == false) {
        rtn.stringValues.add('error getting activity');
        return rtn;
      } else {
        var actFileSync = await syncActivityFilesByAct(
          epsState,
          serverActNow,
          serverAct.item5,
        );

        if (actFileSync.boolValue == false) {
          rtn.stringValues.add('error adding activity file');
          return rtn;
        }
      }
    }

    //

    rtn.boolValue = true;
    return rtn;
  }

  static Future<BoolListStringTuple> syncActivityNotesByAct(
    EpsState epsState,
    Activity activity,
    List<ActivityNote> activityNotes,
  ) async {
    // "regular sync"
    // but act notes are not editable
    // so add new from server
    // post new from local

    var rtn = BoolListStringTuple();

    var serverIds = List<int>();

    for (var serverNote in activityNotes) {
      await ActivityNoteQueries.insertActivityNoteServer(
        epsState.database.database,
        serverNote,
      );
      serverIds.add(serverNote.id);
    }

    // add new local
    var localQuery = await ActivityNoteQueries.getLocalNotesByActivityId(
      epsState.database.database,
      activity.activityDefinitionId,
    );
    for (var localNote in localQuery) {
      var sendResult = await ActivityNoteAdd.add(
        epsState,
        activity.id,
        localNote,
      );
      if (sendResult.item1 == false) {
        // error
        rtn.boolValue = false;
        rtn.stringValues.add('error adding local activity note to server');
        return rtn;
      } else {
        // remove the local value
        await ActivityNoteQueries.deleteActivityNoteLocal(
          epsState.database.database,
          localNote.id,
        );

        // add it to server
        await ActivityNoteQueries.insertActivityNoteServer(
          epsState.database.database,
          sendResult.item2,
        );
        serverIds.add(sendResult.item2.id);
      }
    }

    // delete locals in server table not in server data
    // get locals
    var localNotes = await ActivityNoteQueries.getServerNotesByActivityId(
      epsState.database.database,
      activity.id,
    );
    for (var local in localNotes) {
      if (!serverIds.contains(local.id)) {
        await ActivityNoteQueries.deleteActivityNoteServer(
          epsState.database.database,
          local.id,
        );
      }
    }

    rtn.boolValue = true;
    return rtn;
  }

  static Future<BoolListStringTuple> syncActivityFilesByAct(
    EpsState epsState,
    Activity activity,
    List<ActivityFile> activityFiles,
  ) async {
    // "regular sync"
    // but activity files are not eidtable
    // so add new from server
    // post new from local

    var rtn = BoolListStringTuple();

    var serverIds = List<int>();

    for (var serverFile in activityFiles) {
      await ActivityFileQueries.insertActivityFile(
        epsState.database.database,
        serverFile,
      );
      serverIds.add(serverFile.id);
    }

    // add new local
    var localQuery = await ActivityFileQueries.getLocalActivityFilesByActivity(
      epsState.database.database,
      activity.id,
    );
    for (var localactivityNote in localQuery) {
      var sendResult = await UploadDocument.uploadDocumentAsync(
        epsState,
        null,
        null,
        null,
      );
      if (sendResult.item1 == false) {
        // error
        rtn.boolValue = false;
        rtn.stringValues.add('error adding local activity note to server');
        return rtn;
      } else {
        // remove the local value
        await ActivityFileQueries.deleteLocal(
          epsState.database.database,
          localactivityNote.id,
        );

        // add it to server
        await ActivityFileQueries.insertActivityFile(
          epsState.database.database,
          //sendResult.item2,
          null,
        );
        serverIds.add(sendResult.item2.id);
      }
    }

    // delete locals in server table not in server data
    // get locals
    var localactivities = await ActivityFileQueries.getActivityFilesByActivity(
      epsState.database.database,
      activity.id,
    );
    for (var local in localactivities) {
      if (!serverIds.contains(local.id)) {
        await ActivityFileQueries.delete(
          epsState.database.database,
          local.id,
        );
      }
    }

    rtn.boolValue = true;
    return rtn;
  }

  //
}
