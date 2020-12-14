import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/permission.dart';

class PermissionQueries {
  static Future<void> insertPermission(
    Database database,
    Permission permission,
  ) async {
    await database.insert(
      Permission.getTableName(),
      permission.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deletePermission(
    Database database,
    int value,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + Permission.getTableName() + ' WHERE value = ?',
      [value.toString()],
    );
  }

  static Future<Permission> getPermissionByValue(
    Database database,
    int value,
  ) async {
    var query =
        Permission.getTableName() + ' WHERE value = ' + value.toString() + ';';
    List<Map> result = await database.query(query);
    var results = new List<Permission>();
    result.forEach((row) => results.add(Permission.fromMap(row)));
    return results.first;
  }

  static Future<Permission> getPermissionByCode(
    Database database,
    String code,
  ) async {
    var query = Permission.getTableName() + ' WHERE code = \'' + code + '\';';
    List<Map> result = await database.query(query);
    var results = new List<Permission>();
    result.forEach((row) => results.add(Permission.fromMap(row)));
    return results.first;
  }

  static Future<List<int>> getAllPermissionValues(
    Database database,
  ) async {
    var list = new List<int>();
    List<Map> data = await database
        .rawQuery('SELECT value FROM ' + Permission.getTableName() + ';');
    for (var item in data) {
      if (item.containsKey('value')) {
        list.add(item['value']);
      }
    }
    return list;
  }

  static Future<List<Permission>> getAll(
    Database database,
  ) async {
    var list = new List<Permission>();
    List<Map> data = await database
        .rawQuery('SELECT * FROM ' + Permission.getTableName() + ';');
    for (var item in data) {
      list.add(Permission.fromMap(item));
    }
    return list;
  }
}
