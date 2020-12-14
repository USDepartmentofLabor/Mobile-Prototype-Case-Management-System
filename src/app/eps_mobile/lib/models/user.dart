import 'package:eps_mobile/models/user_role.dart';

class User {
  String jwtToken;

  int id;
  String email;
  String username;
  String name;
  String location;
  String color;

  DateTime createdAt;
  DateTime updatedAt;
  DateTime lastSeenAt;

  bool isActive;
  int userRoleId;

  User() {
    this.jwtToken = '';

    this.id = -1;
    this.email = '';
    this.username = '';
    this.name = '';
    this.location = '';
    this.color = '';

    this.createdAt = null;
    this.updatedAt = null;
    this.lastSeenAt = null;

    this.isActive = false;
    this.userRoleId = -1;
  }

  bool userIsAuthenticated() {
    return (jwtToken != '');
  }

  Map<String, dynamic> toMap() {
    return {
      'jwtToken': jwtToken,
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'location': location,
      'color': color,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'lastSeenAt': lastSeenAt.toString(),
      'isActive': isActive.toString(),
      'userRoleId': userRoleId,
    };
  }

  static User fromMap(Map map) {
    var user = new User();

    var idKey = 'id';
    if (map.containsKey(idKey)) {
      user.id = map[idKey];
    }

    var createdAtKey = 'createdAt';
    if (map.containsKey(createdAtKey)) {
      user.createdAt = DateTime.parse(map[createdAtKey]);
    }

    var emailKey = 'email';
    if (map.containsKey(emailKey)) {
      user.email = map[emailKey];
    }

    var lastSeenAtKey = 'lastSeenAt';
    if (map.containsKey(lastSeenAtKey)) {
      user.lastSeenAt = DateTime.parse(map[lastSeenAtKey]);
    }

    var locationKey = 'location';
    if (map.containsKey(locationKey)) {
      user.location = map[locationKey];
    }

    var nameKey = 'name';
    if (map.containsKey(nameKey)) {
      user.name = map[nameKey];
    }

    var updatedAtKey = 'updatedAt';
    if (map.containsKey(updatedAtKey)) {
      user.updatedAt = DateTime.parse(map[updatedAtKey]);
    }

    var usernameKey = 'username';
    if (map.containsKey(usernameKey)) {
      user.username = map[usernameKey];
    }

    var isActiveKey = 'isActive';
    if (map.containsKey(isActiveKey)) {
      user.isActive = map[isActiveKey] == 'true' ? true : false;
    }

    // user role
    var roleKey = 'userRoleId';
    if (map.containsKey(roleKey)) {
      user.userRoleId = map[roleKey];
    }

    var colorKey = 'color';
    if (map.containsKey(colorKey)) {
      user.color = map[colorKey];
    }

    return user;
  }

  @override
  String toString() {
    return 'User{' +
        'id: $id, ' +
        'name: $name, ' +
        'createdAt: $createdAt, ' +
        'email: $email, ' +
        'lastSeenAt: $lastSeenAt, ' +
        'location: $location, ' +
        'updatedAt: $updatedAt, ' +
        'username: $username, ' +
        'isActive: $isActive, ' +
        'userRoleId: $userRoleId, ' +
        'jwtToken: $jwtToken' +
        'color: $color' +
        '}';
  }

  static String getTableName() {
    return 'users';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(id INTEGER PRIMARY KEY, ' +
        'name TEXT, ' +
        'createdAt TEXT, ' + // SQLite "Datetime"
        'email TEXT, ' +
        'lastSeenAt TEXT, ' + // SQLite "Datetime"
        'location TEXT, ' +
        'updatedAt TEXT, ' + // SQLite "Datetime"
        'username TEXT, ' +
        'isActive INTEGER, ' +
        'userRoleId INT, ' +
        'jwtToken TEXT, ' +
        'color TEXT, ' +
        'FOREIGN KEY (userRoleId) REFERENCES ' +
        UserRole.getTableName() +
        '(id)' +
        ');';
  }
}
