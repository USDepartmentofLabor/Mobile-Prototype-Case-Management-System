import 'package:eps_mobile/models/bool_list_string_tuple.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/survey.dart';
//import 'package:eps_mobile/models/survey_response.dart';
import 'package:eps_mobile/queries/survey_response_queries.dart';
import 'package:eps_mobile/service_helpers/survey_response_edit.dart';
import 'package:eps_mobile/service_helpers/survey_response_get.dart';
import 'package:eps_mobile/service_helpers/survey_response_post.dart';
//import 'package:tuple/tuple.dart';

class SurveyResponsesSync {
  static Future<BoolListStringTuple> fullSync(
    EpsState epsState,
    List<Survey> surveyDefinitions,
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

    // get all from server by each definition
    //var serverData = List<Tuple2<Survey, List<SurveyResponse>>>();
    for (var surveyDef in surveyDefinitions) {
      var getResponses = await SurveyResponseGet.getAllBySurveyId(
        epsState.user.jwtToken,
        epsState.serviceInfo.url,
        epsState.serviceInfo.useHttps,
        surveyDef.id,
      );

      // if (getResponses.item1 == true) {
      //   serverData.add(Tuple2<Survey, List<SurveyResponse>>(
      //     surveyDef,
      //     getResponses.item3,
      //   ));
      // }

      if (getResponses.item1 == false) {
        // error
        rtn.boolValue = false;
        rtn.stringValues.add('error getting survey responses');
        return rtn;
      }

      // compare to local
      var serverIds = List<int>();
      for (var server in getResponses.item3) {
        serverIds.add(server.id);
        var query = await SurveyResponseQueries
            .getSurveyResponseBySurveyResponseIdServer(
          epsState.database.database,
          server.id,
        );
        if (query != null) {
          // match - compare
          if (server.updatedAt.microsecondsSinceEpoch >=
              query.updatedAt.microsecondsSinceEpoch) {
            // server wins - replace local
            SurveyResponseQueries.insertSurveyResponse(
              epsState.database.database,
              server,
            );
          } else {
            // local wins - send to server
            var sendResult = await SurveyResponseEdit(epsState).editResponse(
              epsState.serviceInfo.url,
              epsState.serviceInfo.useHttps,
              surveyDef,
              query,
              null,
            );
            if (sendResult.item1 == false) {
              // error
              rtn.boolValue = false;
              rtn.stringValues.add('error updating survey response to server');
              return rtn;
            }
          }
        } else {
          // new from server - add it here
          SurveyResponseQueries.insertSurveyResponse(
            epsState.database.database,
            server,
          );
        }
      }

      // add new local
      var localLocalResponses =
          await SurveyResponseQueries.getSurveyResponsesByDefIdLocal(
        epsState.database.database,
        surveyDef.id,
      );
      for (var localResponse in localLocalResponses) {
        var sendResult = await SurveyResponsePost(epsState).postResponse(
          epsState.serviceInfo.url,
          epsState.serviceInfo.useHttps,
          surveyDef,
          localResponse,
          null,
        );
        if (sendResult.item1 == false) {
          // error
          rtn.boolValue = false;
          rtn.stringValues
              .add('error updating local survey response to server');
          return rtn;
        } else {
          // remove the local value
          await SurveyResponseQueries.deleteSurveyResponseLocal(
            epsState.database.database,
            localResponse.id,
          );

          // add it to server
          await SurveyResponseQueries.insertSurveyResponse(
            epsState.database.database,
            sendResult.item2,
          );
          serverIds.add(sendResult.item2.id);
        }
      }

      // delete locals in server table not in server data
      // get locals
      var localServerResponses =
          await SurveyResponseQueries.getSurveyResponsesByDefIdServer(
        epsState.database.database,
        surveyDef.id,
      );
      for (var local in localServerResponses) {
        if (!serverIds.contains(local.id)) {
          await SurveyResponseQueries.deleteSurveyResponse(
            epsState.database.database,
            local.id,
          );
        }
      }
    }

    // is there a case for any leftovers/abandoned?

    rtn.boolValue = true;
    return rtn;
  }
}
