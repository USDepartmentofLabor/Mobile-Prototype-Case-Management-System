import 'dart:core';
import 'package:eps_mobile/helpers/enum_helper.dart';
import 'package:eps_mobile/helpers/permissions_helper.dart';
import 'package:eps_mobile/models/permission_values.dart';
import 'package:eps_mobile/queries/permission_queries.dart';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/user.dart';

class UserQueries {
  static Future<void> insertUser(
    Database database,
    User user,
  ) async {
    await database.insert(
      User.getTableName(),
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> delete(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
        'DELETE FROM ' + User.getTableName() + ' WHERE id = ?',
        [id.toString()]);
  }

  static Future<List<User>> getAllUsers(
    Database database,
  ) async {
    var list = new List<User>();
    List<Map> data = await database.rawQuery(
      'SELECT * FROM ' + User.getTableName() + ';',
    );
    for (var item in data) {
      list.add(
        User.fromMap(
          item,
        ),
      );
    }
    return list;
  }

  static Future<List<User>> getUsersWithPermissions(
    Database database,
    List<PermissionValues> permissions,
  ) async {
    var list = new List<User>();
    for (var user in await getAllUsers(database)) {
      var permissionsCount = 0;
      for (var permission in permissions) {
        var permissionQuery = await PermissionQueries.getPermissionByCode(
          database,
          EnumHelper.enumToString(permission),
        );
        if (permissionQuery != null) {
          if (await PermissionsHelper.userHasPermission(
            database,
            user,
            permissionQuery,
          )) {
            permissionsCount++;
          }
        } else {
          // error
        }
      }
      if (permissionsCount == permissions.length) {
        list.add(user);
      }
    }
    return list;
  }

  static Future<bool> getUserIdExists(
    Database database,
    int userId,
  ) async {
    var query = 'SELECT COUNT(*) FROM ' +
        User.getTableName() +
        ' WHERE id = ' +
        userId.toString() +
        ';';
    return Sqflite.firstIntValue(await database.rawQuery(query)) == 1;
  }

  static Future<User> getUserById(
    Database database,
    int id,
  ) async {
    var query = 'SELECT * FROM ' +
        User.getTableName() +
        ' WHERE id = ' +
        id.toString() +
        ';';
    List<Map> result = await database.rawQuery(
      query,
    );
    var results = new List<User>();
    result.forEach((row) => results.add(User.fromMap(row)));
    return results.length > 0 ? results.first : null;
  }

  static Future<void> updateUser(
    Database database,
    User user,
  ) async {
    await database.update(User.getTableName(), user.toMap());
  }
}
