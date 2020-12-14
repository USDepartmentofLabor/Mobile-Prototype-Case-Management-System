import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/project.dart';

class ProjectQueries {
  static Future<void> insertProject(
    Database database,
    Project project,
  ) async {
    await database.insert(
      Project.getTableName(),
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Project> getProject(
    Database database,
  ) async {
    var list = new List<Project>();
    List<Map> data = await database.rawQuery(
      'SELECT * FROM ' + Project.getTableName() + ';',
    );
    for (var item in data) {
      list.add(
        Project.fromMap(
          item,
        ),
      );
    }
    return list.first;
  }
}
