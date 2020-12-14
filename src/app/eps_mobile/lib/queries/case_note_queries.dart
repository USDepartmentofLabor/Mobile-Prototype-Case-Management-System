import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/case_note.dart';

class CaseNoteQueries {
  static Future<void> insertCaseNote(
    Database database,
    CaseNote caseNote,
  ) async {
    await database.insert(
      CaseNote.getTableName(),
      caseNote.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertLocalCaseNote(
    Database database,
    CaseNote caseNote,
  ) async {
    // get next id
    var id = 1;
    var count = Sqflite.firstIntValue(
      await database.rawQuery(
        'SELECT COUNT(*) ' + CaseNote.getAltTableName() + ';',
      ),
    );
    if (count > 0) {
      var idQuery = Sqflite.firstIntValue(
        await database.rawQuery(
          'SELECT MAX(id) from ' + CaseNote.getAltTableName() + ';',
        ),
      );
      id = idQuery + 1;
    }
    caseNote.id = id;
    await database.insert(
      CaseNote.getAltTableName(),
      caseNote.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteCaseNote(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + CaseNote.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<void> deleteCaseNoteLocal(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + CaseNote.getAltTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<CaseNote> getByIdServer(
    Database database,
    int id,
  ) async {
    var query = CaseNote.getTableName() + ' WHERE id = ' + id.toString() + ';';
    List<Map> result = await database.query(
      query,
    );
    if (result.length == 0) {
      return null;
    } else {
      var results = new List<CaseNote>();
      result.forEach((row) => results.add(CaseNote.fromMap(row)));
      return results.first;
    }
  }

  static Future<CaseNote> getByIdLocal(
    Database database,
    int id,
  ) async {
    var query =
        CaseNote.getAltTableName() + ' WHERE id = ' + id.toString() + ';';
    List<Map> result = await database.query(
      query,
    );
    if (result.length == 0) {
      return null;
    } else {
      var results = new List<CaseNote>();
      result.forEach((row) => results.add(CaseNote.fromMap(row)));
      return results.first;
    }
  }

  static Future<List<CaseNote>> getCaseNotesByCase(
    Database database,
    CaseInstance caseInstance,
  ) async {
    var caseNotes = new List<CaseNote>();
    var query = 'SELECT * FROM ' +
        CaseNote.getTableName() +
        ' WHERE caseId = ' +
        caseInstance.id.toString() +
        ';';
    List<Map> data = await database.rawQuery(query);
    for (var caseNote in data) {
      caseNotes.add(CaseNote.fromMap(caseNote));
    }
    return caseNotes;
  }

  static Future<List<CaseNote>> getLocalCaseNotesByCase(
    Database database,
    CaseInstance caseInstance,
  ) async {
    var caseNotes = new List<CaseNote>();
    var query = 'SELECT * FROM ' +
        CaseNote.getAltTableName() +
        ' WHERE caseId = ' +
        caseInstance.id.toString() +
        ';';
    List<Map> data = await database.rawQuery(query);
    for (var caseNote in data) {
      caseNotes.add(CaseNote.fromMap(caseNote));
    }
    return caseNotes;
  }
}
