import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/user.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Login {
  User user;

  Login(String username) {
    this.user = new User();
    this.user.username = username;
  }

  Future<Tuple2<bool, EpsState>> signIn(
    String password,
    String serviceUrl,
    bool useHttps,
  ) async {
    var headers = {
      "Content-Type": "application/json",
    };

    var body = {};

    // get location
    var location = await EpsState().geolocationHelper.getLocation();
    if (location != null) {
      body = {
        'login': user.username,
        'password': password,
      };
      body['latitude'] = location.latitude;
      body['longitude'] = location.longitude;
      body['position_accuracy'] = location.accuracy;
      body['altitude'] = location.altitude;
      body['altitude_accuracy'] = 0.0;
      body['heading'] = location.heading;
      body['speed'] = location.speed;
    } else {
      body = {
        'login': user.username,
        'password': password,
      };
    }

    Uri logInUri;

    if (useHttps) {
      logInUri = Uri.https(serviceUrl, '/auth/login');
    } else {
      logInUri = Uri.http(serviceUrl, '/auth/login');
    }

    final logInResponse =
        await http.post(logInUri, headers: headers, body: jsonEncode(body));

    if (logInResponse.statusCode == 200) {
      // parse success response
      var responseData = json.decode(logInResponse.body);

      var user = new User();

      if (responseData.containsKey('access_token')) {
        user.jwtToken = responseData['access_token'];
      }

      if (responseData.containsKey('profile')) {
        var profile = responseData['profile'];

        if (profile.containsKey('created_at')) {
          user.createdAt = DateTime.parse(profile['created_at']);
        }

        if (profile.containsKey('email')) {
          user.email = profile['email'];
        }

        if (profile.containsKey('id')) {
          user.id = profile['id'];
        }

        if (profile.containsKey('last_seen_at')) {
          user.lastSeenAt = DateTime.parse(profile['last_seen_at']);
        }

        if (profile.containsKey('location')) {
          user.location = profile[''];
        }

        if (profile.containsKey('name')) {
          user.name = profile['name'];
        }

        if (profile.containsKey('color')) {
          user.color = profile['color'];
        }

        // role
        var roleKey = 'role';
        if (profile.containsKey(roleKey)) {
          var roleData = profile[roleKey];
          var roleIdKey = 'id';
          if (roleData.containsKey(roleIdKey)) {
            user.userRoleId = roleData[roleIdKey];
          }
        }

        if (profile.containsKey('updated_at')) {
          user.updatedAt = DateTime.parse(profile['updated_at']);
        }

        if (profile.containsKey('username')) {
          user.username = profile['username'];
        }
      }

      var epsState = new EpsState();
      epsState.user = user;

      return Tuple2<bool, EpsState>(true, epsState);
    }

    // failure
    return Tuple2<bool, EpsState>(false, null);
  }
}
