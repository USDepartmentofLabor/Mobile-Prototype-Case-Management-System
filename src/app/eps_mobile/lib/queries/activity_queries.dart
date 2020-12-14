import 'dart:core';
import 'package:eps_mobile/queries/activity_definition_queries.dart';
import 'package:sqflite/sqflite.dart';
import 'package:eps_mobile/models/activity_definition.dart';
import 'package:eps_mobile/models/activity.dart';
import 'package:tuple/tuple.dart';

import '../models/activity_definition.dart';
import 'activity_definition_queries.dart';

class ActivityQueries {
  static Future<void> insertActivity(
    Database database,
    Activity activity,
  ) async {
    await database.insert(
      Activity.getTableName(),
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertActivityLocal(
    Database database,
    Activity activity,
  ) async {
    await database.insert(
      Activity.getLocalTableName(),
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> delete(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + Activity.getTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<void> deleteLocal(
    Database database,
    int id,
  ) async {
    await database.rawDelete(
      'DELETE FROM ' + Activity.getLocalTableName() + ' WHERE id = ?',
      [id.toString()],
    );
  }

  static Future<Activity> getByIdServer(
    Database database,
    int id,
  ) async {
    var query = Activity.getTableName() + ' WHERE id = ' + id.toString() + ';';
    List<Map> result = await database.query(
      query,
    );
    if (result.length == 0) {
      return null;
    } else {
      var results = new List<Activity>();
      result.forEach((row) => results.add(Activity.fromMap(row)));
      return results.first;
    }
  }

  static Future<Activity> getByIdLocal(
    Database database,
    int id,
  ) async {
    var query =
        Activity.getLocalTableName() + ' WHERE id = ' + id.toString() + ';';
    List<Map> result = await database.query(
      query,
    );
    var results = new List<Activity>();
    result.forEach((row) {
      var obj = Activity.fromMap(row);
      obj.isLocal = true;
      results.add(obj);
    });
    return results.first;
  }

  static Future<List<Activity>> getAllLocal(
    Database database,
  ) async {
    var list = new List<Activity>();
    List<Map> data = await database.rawQuery(
      'SELECT * FROM ' + Activity.getLocalTableName() + ';',
    );
    for (var item in data) {
      var obj = Activity.fromMap(item);
      obj.isLocal = true;
      list.add(obj);
    }
    return list;
  }

  static Future<List<Activity>> getAllActivitys(
    Database database,
  ) async {
    var list = new List<Activity>();
    List<Map> data = await database.rawQuery(
      'SELECT * FROM ' + Activity.getTableName() + ';',
    );
    for (var item in data) {
      list.add(Activity.fromMap(item));
    }
    return list;
  }

  static Future<bool> getActivityIdExistsLocal(
    Database database,
    int activityId,
  ) async {
    var query = 'select COUNT(*) as COUNT from ' +
        Activity.getTableName() +
        ' where id = ' +
        activityId.toString() +
        ';';
    var count = Sqflite.firstIntValue(await database.rawQuery(
      query,
    ));
    return (count == 1);
  }

  static Future<Tuple2<List<ActivityDefinition>, List<Activity>>>
      getActivitiesAndDefinitionsByCaseIdIncludeZero(
    Database database,
    int caseId,
    int caseDefinitionId,
  ) async {
    var definitions = List<ActivityDefinition>();
    var activities = List<Activity>();

    var definitionsQueryResults =
        await ActivityDefinitionQueries.getAllActivityDefinitions(
      database,
    );
    for (var definition in definitionsQueryResults) {
      if (definition.caseDefinitionId == caseDefinitionId) {
        definitions.add(definition);
        var acts =
            await ActivityQueries.getActivitiesByCaseIdAndActivityDefinition(
          database,
          caseId,
          definition.id,
        );
        activities.addAll(acts);
      }
    }

    return Tuple2<List<ActivityDefinition>, List<Activity>>(
      definitions,
      activities,
    );
  }

  static Future<Tuple2<List<ActivityDefinition>, List<Activity>>>
      getActivitiesAndDefinitionsByCaseId(
    Database database,
    int caseId,
  ) async {
    var query = 'SELECT * FROM ' +
        Activity.getTableName() +
        ' where caseId = ' +
        caseId.toString() +
        ';';
    List<Map> data = await database.rawQuery(query);
    var activityDefinitionIds = List<int>();
    var activities = List<Activity>();
    var activityDefinitions = List<ActivityDefinition>();
    for (var item in data) {
      var activity = Activity.fromMap(item);
      activities.add(activity);

      if (!activityDefinitionIds.contains(activity.activityDefinitionId)) {
        activityDefinitionIds.add(activity.activityDefinitionId);
        activityDefinitions
            .add(await ActivityDefinitionQueries.getActivityDefinitionById(
          database,
          activity.activityDefinitionId,
        ));
      }
    }
    return Tuple2<List<ActivityDefinition>, List<Activity>>(
      activityDefinitions,
      activities,
    );
  }

  static Future<List<Activity>> getActivitiesByCaseIdAndActivityDefinition(
    Database database,
    int caseId,
    int activityDefinitionId,
  ) async {
    var query = 'SELECT * FROM ' +
        Activity.getTableName() +
        ' where ' +
        'caseId = ' +
        caseId.toString() +
        ' AND ' +
        ' activityDefinitionId = ' +
        activityDefinitionId.toString() +
        ';';
    var list = new List<Activity>();
    List<Map> data = await database.rawQuery(
      query,
    );
    for (var item in data) {
      list.add(Activity.fromMap(item));
    }
    return list;
  }
}
