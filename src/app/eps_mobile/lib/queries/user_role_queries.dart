import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/user_role.dart';

class UserRoleQueries {
  static Future<void> insertUserRole(
    Database database,
    UserRole userRole,
  ) async {
    await database.insert(
      UserRole.getTableName(),
      userRole.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteUserRole(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
        'DELETE FROM ' + UserRole.getTableName() + ' WHERE id = ?',
        [id.toString()]);
  }

  static Future<UserRole> getUserRoleById(
    Database database,
    int userRoleId,
  ) async {
    var query = 'SELECT * FROM ' +
        UserRole.getTableName() +
        ' WHERE id = ' +
        userRoleId.toString() +
        ';';
    List<Map> result = await database.rawQuery(
      query,
    );
    var results = new List<UserRole>();
    result.forEach((row) => results.add(UserRole.fromMap(row)));
    return results.length > 0 ? results.first : null;
  }

  static Future<bool> getUserRoleIdExists(
    Database database,
    int userRoleId,
  ) async {
    var query = 'SELECT COUNT(*) FROM ' +
        UserRole.getTableName() +
        ' WHERE id = ' +
        userRoleId.toString() +
        ';';
    return Sqflite.firstIntValue(await database.rawQuery(query)) == 1;
  }

  static Future<List<int>> getAllUserRoleIds(
    Database database,
  ) async {
    var list = new List<int>();
    List<Map> data = await database
        .rawQuery('SELECT id FROM ' + UserRole.getTableName() + ';');
    for (var item in data) {
      if (item.containsKey('id')) {
        list.add(item['id']);
      }
    }
    return list;
  }

  static Future<List<UserRole>> getAllUserRoles(
    Database database,
  ) async {
    var userRoles = new List<UserRole>();
    List<Map> queryResults = await database.query(UserRole.getTableName());
    for (var userRole in queryResults) {
      userRoles.add(UserRole.fromMap(userRole));
    }
    return userRoles;
  }
}
