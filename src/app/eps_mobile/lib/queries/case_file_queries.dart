import 'dart:core';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/case_file.dart';

class CaseFileQueries {
  static Future<void> insertCaseFile(
    Database database,
    CaseFile caseFile,
  ) async {
    await database.insert(
      CaseFile.getTableName(),
      caseFile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertLocalCaseFile(
    Database database,
    CaseFile caseFile,
  ) async {
    await database.insert(
      CaseFile.getAltTableName(),
      caseFile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> delete(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + CaseFile.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<void> deleteLocal(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + CaseFile.getAltTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<List<CaseFile>> getCaseFilesByCase(
    Database database,
    CaseInstance caseInstance,
  ) async {
    var caseFiles = new List<CaseFile>();
    var query = 'SELECT * FROM ' +
        CaseFile.getTableName() +
        ' WHERE caseId = ' +
        caseInstance.id.toString() +
        ';';
    List<Map> data = await database.rawQuery(query);
    for (var caseNote in data) {
      caseFiles.add(CaseFile.fromMap(caseNote));
    }
    return caseFiles;
  }

  static Future<List<CaseFile>> getLocalCaseFilesByCase(
    Database database,
    CaseInstance caseInstance,
  ) async {
    var caseFiles = new List<CaseFile>();
    var query = 'SELECT * FROM ' +
        CaseFile.getAltTableName() +
        ' WHERE caseId = ' +
        caseInstance.id.toString() +
        ';';
    List<Map> data = await database.rawQuery(query);
    for (var caseNote in data) {
      caseFiles.add(CaseFile.fromMap(caseNote));
    }
    return caseFiles;
  }
}
