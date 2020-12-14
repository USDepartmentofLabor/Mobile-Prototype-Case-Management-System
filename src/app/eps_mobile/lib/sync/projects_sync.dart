import 'package:eps_mobile/models/bool_list_string_tuple.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/service_helpers/project_get.dart';
import 'package:eps_mobile/queries/project_queries.dart';

class ProjectsSync {
  static Future<BoolListStringTuple> fullsync(
    EpsState epsState,
  ) async {
    var rtn = BoolListStringTuple();

    var getResult = await ProjectGet.getProject(
      epsState,
    );

    if (getResult.item1) {
      ProjectQueries.insertProject(
        epsState.database.database,
        getResult.item2,
      );

      rtn.boolValue = true;
      return rtn;
    }

    // failure
    return rtn;
  }
}
