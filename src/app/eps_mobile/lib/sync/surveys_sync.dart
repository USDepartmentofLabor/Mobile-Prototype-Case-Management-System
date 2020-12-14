import 'package:eps_mobile/models/bool_list_string_tuple.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/queries/survey_queries.dart';
import 'package:eps_mobile/service_helpers/surveys_get_all.dart';

class SurveysSync {
  static Future<BoolListStringTuple> fullSync(
    EpsState epsState,
  ) async {
    // simple sync
    // i.e. no changes from the app
    // server is the only source of truth

    var rtn = BoolListStringTuple();

    // get all from server
    var serverData = await SurveysGetAll(epsState).getAllSurveys(
      epsState.serviceInfo.url,
      epsState.serviceInfo.useHttps,
    );

    if (serverData.item1) {
      // get all locals
      var existingLocal = await SurveyQueries.getAllSurveys(
        epsState.database.database,
      );

      // server adds/updates
      var serverIds = List<int>();
      for (var object in serverData.item2) {
        serverIds.add(object.id);
        SurveyQueries.insertSurvey(
          epsState.database.database,
          object,
        );
      }

      // delete locals not on server
      for (var localObject in existingLocal) {
        if (!serverIds.contains(localObject.id)) {
          SurveyQueries.deleteSurvey(
            epsState.database.database,
            localObject.id,
          );
        }
      }

      rtn.boolValue = true;
    } else {
      rtn.stringValues.add(
        'error',
      );
    }

    return rtn;
  }
}
