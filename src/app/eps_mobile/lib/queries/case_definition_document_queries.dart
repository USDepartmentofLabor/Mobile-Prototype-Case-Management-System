import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/case_definition_document.dart';

class CaseDefinitionDocumentQueries {
  static Future<void> insertCaseDefinitionDocument(
    Database database,
    CaseDefinitionDocument caseDefinitionDocument,
  ) async {
    await database.insert(
      CaseDefinitionDocument.getTableName(),
      caseDefinitionDocument.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> delete(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + CaseDefinitionDocument.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<List<CaseDefinitionDocument>>
      getCaseDefinitionDocumentsByCaseDefinitionId(
    Database database,
    int caseDefinitionId,
  ) async {
    var query = 'SELECT * FROM ' +
        CaseDefinitionDocument.getTableName() +
        ' WHERE caseDefinitionId = ' +
        caseDefinitionId.toString() +
        ';';
    List<Map> result = await database.rawQuery(
      query,
    );
    var results = new List<CaseDefinitionDocument>();
    result.forEach((row) => results.add(CaseDefinitionDocument.fromMap(row)));
    return results;
  }

  static Future<int> getCaseDefinitionDocumentCountById(
    Database database,
    int caseDefinitionId,
    int caseDefinitionDocumentId,
  ) async {
    var query = 'select COUNT(*) as COUNT from ' +
        CaseDefinitionDocument.getTableName() +
        ' where id = ' +
        caseDefinitionDocumentId.toString() +
        ' and caseDefinitionId = ' +
        caseDefinitionId.toString() +
        ';';
    return Sqflite.firstIntValue(
      await database.rawQuery(
        query,
      ),
    );
  }
}
