import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/activity.dart';
import 'package:eps_mobile/models/activity_note.dart';

class ActivityNoteQueries {
  static Future<void> insertActivityNoteServer(
    Database database,
    ActivityNote activityNote,
  ) async {
    await database.insert(
      ActivityNote.getTableName(),
      activityNote.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertActivityNoteLocal(
    Database database,
    ActivityNote activityNote,
  ) async {
    await database.insert(
      ActivityNote.getLocalTableName(),
      activityNote.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteActivityNoteServer(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + ActivityNote.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<void> deleteActivityNoteLocal(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + ActivityNote.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<List<ActivityNote>> getServerNotesByActivityId(
    Database database,
    int activityId,
  ) async {
    var notes = new List<ActivityNote>();
    var query = 'SELECT * FROM ' +
        ActivityNote.getTableName() +
        ' WHERE activityId = ' +
        activityId.toString() +
        ';';
    List<Map> data = await database.rawQuery(query);
    for (var caseNote in data) {
      notes.add(ActivityNote.fromMap(caseNote));
    }
    return notes;
  }

  static Future<List<ActivityNote>> getLocalNotesByActivityId(
    Database database,
    int activityId,
  ) async {
    var notes = new List<ActivityNote>();
    var query = 'SELECT * FROM ' +
        ActivityNote.getLocalTableName() +
        ' WHERE activityId = ' +
        activityId.toString() +
        ';';
    List<Map> data = await database.rawQuery(query);
    for (var caseNote in data) {
      notes.add(ActivityNote.fromMap(caseNote));
    }
    return notes;
  }

  static Future<List<ActivityNote>> getActivityNotesByActivityServer(
    Database database,
    Activity activity,
  ) async {
    var notes = new List<ActivityNote>();
    var query = 'SELECT * FROM ' +
        ActivityNote.getTableName() +
        ' WHERE activityId = ' +
        activity.id.toString() +
        ';';
    List<Map> data = await database.rawQuery(query);
    for (var activityNote in data) {
      notes.add(ActivityNote.fromMap(activityNote));
    }
    return notes;
  }

  static Future<List<ActivityNote>> getActivityNotesByActivityLocal(
    Database database,
    Activity activity,
  ) async {
    var notes = new List<ActivityNote>();
    var query = 'SELECT * FROM ' +
        ActivityNote.getLocalTableName() +
        ' WHERE activityId = ' +
        activity.id.toString() +
        ';';
    List<Map> data = await database.rawQuery(query);
    for (var activityNote in data) {
      notes.add(ActivityNote.fromMap(activityNote));
    }
    return notes;
  }
}
