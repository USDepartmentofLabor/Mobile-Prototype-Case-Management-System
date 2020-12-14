import 'dart:async';
import 'dart:convert';
import 'package:eps_mobile/queries/user_role_queries.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/user.dart';

class UsersGetAll {
  EpsState epsState;

  UsersGetAll(EpsState epsState) {
    this.epsState = epsState;
  }

  Future<Tuple3<bool, List<String>, List<User>>> getAllUsers(
    String serviceUrl,
    bool useHttps,
  ) async {
    var errors = new List<String>();

    Uri logInUri;

    String url = '/users/';

    if (useHttps) {
      logInUri = Uri.https(serviceUrl, url);
    } else {
      logInUri = Uri.http(serviceUrl, url);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + epsState.user.jwtToken
    };

    final response = await http.get(logInUri, headers: headers);
    if (response.statusCode == 200) {
      var users = new List<User>();
      for (var userData in json.decode(response.body)) {
        var user = new User();

        var idKey = 'id';
        if (userData.containsKey(idKey)) {
          user.id = userData[idKey];
        }

        var emailKey = 'email';
        if (userData.containsKey(emailKey)) {
          user.email = userData[emailKey];
        }

        var nameKey = 'name';
        if (userData.containsKey(nameKey)) {
          user.name = userData[nameKey];
        }

        var usernameKey = 'username';
        if (userData.containsKey(usernameKey)) {
          user.username = userData[usernameKey];
        }

        var locationKey = 'location';
        if (userData.containsKey(locationKey)) {
          user.location = userData[locationKey];
        }

        var createdAtKey = 'created_at';
        if (userData.containsKey(createdAtKey)) {
          user.createdAt = DateTime.parse(userData[createdAtKey]);
        }

        var updatedAtKey = 'updated_at';
        if (userData.containsKey(updatedAtKey)) {
          user.updatedAt = DateTime.parse(userData[updatedAtKey]);
        }

        var lastSeenAtKey = 'last_seen_at';
        if (userData.containsKey(lastSeenAtKey)) {
          user.lastSeenAt = DateTime.parse(userData[lastSeenAtKey]);
        }

        var isActiveKey = 'is_active';
        if (userData.containsKey(isActiveKey)) {
          user.isActive = userData[isActiveKey] == 'true' ? true : false;
        }

        var colorKey = 'color';
        if (userData.containsKey(colorKey)) {
          user.color = userData[colorKey];
        }

        var userRoleKey = 'role';
        if (userData.containsKey(userRoleKey)) {
          var userRoleData = userData[userRoleKey];
          var userRoleIdKey = 'id';
          if (userRoleData.containsKey(userRoleIdKey)) {
            var userRoleId = userRoleData[userRoleIdKey];
            var userRoleIdExists = await UserRoleQueries.getUserRoleIdExists(
              epsState.database.database,
              userRoleId,
            );
            if (userRoleIdExists) {
              user.userRoleId = userRoleId;
            }
          }
        }

        users.add(user);
      }

      return new Tuple3<bool, List<String>, List<User>>(
        true,
        errors,
        users,
      );
    } else {
      // get the error code and string
      print(response.bodyBytes.toString());
    }

    return new Tuple3<bool, List<String>, List<User>>(
      false,
      errors,
      new List<User>(),
    );
  }
}
