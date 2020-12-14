import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/case_instance.dart';

class CaseQueries {
  static Future<void> insertCase(
    Database database,
    CaseInstance caseInstance,
  ) async {
    await database.insert(
      CaseInstance.getTableName(),
      caseInstance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertLocal(
    Database database,
    CaseInstance caseInstance,
  ) async {
    caseInstance.id = null;
    await database.insert(
      CaseInstance.getAltTableName(),
      caseInstance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<CaseInstance> getCaseByIdServer(
    Database database,
    int id,
  ) async {
    var query =
        CaseInstance.getTableName() + ' WHERE id = ' + id.toString() + ';';
    List<Map> result = await database.query(
      query,
    );
    if (result.length == 0) {
      return null;
    } else {
      var results = new List<CaseInstance>();
      result.forEach((row) => results.add(CaseInstance.fromMap(row)));
      return results.first;
    }
  }

  static Future<CaseInstance> getCaseByIdLocal(
    Database database,
    int id,
  ) async {
    var query =
        CaseInstance.getAltTableName() + ' WHERE id = ' + id.toString() + ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<CaseInstance>();
    result.forEach((row) {
      var caseInstance = CaseInstance.fromMap(row);
      caseInstance.isLocal = true;
      results.add(caseInstance);
    });
    return results.first;
  }

  static Future<List<CaseInstance>> getAllCasesServer(
    Database database,
  ) async {
    var list = new List<CaseInstance>();
    List<Map> data = await database.rawQuery(
      'SELECT * FROM ' + CaseInstance.getTableName() + ';',
    );
    for (var item in data) {
      list.add(CaseInstance.fromMap(item));
    }
    return list;
  }

  static Future<List<CaseInstance>> getAllCasesLocal(
    Database database,
  ) async {
    var list = new List<CaseInstance>();
    List<Map> data = await database.rawQuery(
      'SELECT * FROM ' + CaseInstance.getAltTableName() + ';',
    );
    for (var item in data) {
      var caseInstance = CaseInstance.fromMap(item);
      caseInstance.isLocal = true;
      list.add(caseInstance);
    }
    return list;
  }

  static Future<List<CaseInstance>> getCasesByDefinitionIdServerOnly(
    Database database,
    int caseDefinitionId,
  ) async {
    var query = CaseInstance.getTableName() +
        ' WHERE caseDefinitionId = ' +
        caseDefinitionId.toString() +
        ' ORDER BY key' +
        ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<CaseInstance>();
    result.forEach((row) => results.add(CaseInstance.fromMap(row)));
    return results;
  }

  static Future<List<CaseInstance>> getCasesByDefinitionIdLocalOnly(
    Database database,
    int caseDefinitionId,
  ) async {
    var query = CaseInstance.getAltTableName() +
        ' WHERE caseDefinitionId = ' +
        caseDefinitionId.toString() +
        ' ORDER BY key' +
        ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<CaseInstance>();
    result.forEach((row) {
      var caseInstance = CaseInstance.fromMap(row);
      caseInstance.isLocal = true;
      results.add(caseInstance);
    });
    return results;
  }

  static Future<List<CaseInstance>> getCasesByDefinitionId(
    Database database,
    int caseDefinitionId,
  ) async {
    var query = CaseInstance.getTableName() +
        ' WHERE caseDefinitionId = ' +
        caseDefinitionId.toString() +
        ' AND markForDeletion = 0 ' +
        ' ORDER BY key' +
        ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<CaseInstance>();
    result.forEach((row) => results.add(CaseInstance.fromMap(row)));
    return results;
  }

  static Future<void> deleteCase(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + CaseInstance.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<void> deleteCaseLocal(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + CaseInstance.getAltTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<List<String>> getAllCaseNamesServerAndLocal(
    Database database,
  ) async {
    var queryServer = CaseInstance.getTableName() + ';';
    var queryLocal = CaseInstance.getAltTableName() + ';';
    List<Map> resultServer = await database.query(
      queryServer,
    );
    List<Map> resultLocal = await database.query(
      queryLocal,
    );
    var results = new List<String>();
    resultServer.forEach((row) => results.add(CaseInstance.fromMap(row).name));
    resultLocal.forEach((row) => results.add(CaseInstance.fromMap(row).name));
    return results;
  }
}
