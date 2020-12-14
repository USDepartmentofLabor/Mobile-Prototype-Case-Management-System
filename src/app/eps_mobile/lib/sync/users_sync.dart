import 'package:eps_mobile/models/bool_list_string_tuple.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/queries/user_queries.dart';
import 'package:eps_mobile/service_helpers/users_get_all.dart';

class UsersSync {
  static Future<BoolListStringTuple> fullSync(
    EpsState epsState,
  ) async {
    // simple sync
    // i.e. no changes from the app
    // server is the only source of truth

    var rtn = BoolListStringTuple();

    // get all from server
    var serverData = await UsersGetAll(epsState).getAllUsers(
      epsState.serviceInfo.url,
      epsState.serviceInfo.useHttps,
    );

    if (serverData.item1) {
      // get all locals
      var existingLocalUsers = await UserQueries.getAllUsers(
        epsState.database.database,
      );

      // server adds/updates
      var serverIds = List<int>();
      for (var object in serverData.item3) {
        serverIds.add(object.id);
        UserQueries.insertUser(
          epsState.database.database,
          object,
        );
      }

      // delete locals not on server
      for (var localObject in existingLocalUsers) {
        if (!serverIds.contains(localObject.id)) {
          UserQueries.delete(
            epsState.database.database,
            localObject.id,
          );
        }
      }

      rtn.boolValue = true;
    } else {
      rtn.stringValues.addAll(
        serverData.item2,
      );
    }

    return rtn;
  }
}
