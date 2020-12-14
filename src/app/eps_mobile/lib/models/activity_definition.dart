import 'package:eps_mobile/models/activity_definition_document.dart';
import 'package:eps_mobile/models/case_definition.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/models/user.dart';

class ActivityDefinition {
  // fields
  int id;
  String name;
  String description;
  String customFieldData;

  // relationships
  int caseDefinitionId;

  // surveys for get
  List<Survey> surveys;

  // docs for get
  List<ActivityDefinitionDocument> docs;

  // datetime and users
  DateTime createdAt;
  int createdBy;

  DateTime updatedAt;
  int updatedBy;

  ActivityDefinition() {
    this.id = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'customFieldData': customFieldData,
      'caseDefinitionId': caseDefinitionId,
      'createdAt': createdAt.toString(),
      'createdBy': createdBy,
      'updatedAt': updatedAt.toString(),
      'updatedBy': updatedBy,
    };
  }

  static ActivityDefinition fromMap(Map map) {
    var object = ActivityDefinition();

    var idKey = 'id';
    if (map.containsKey(idKey)) {
      object.id = map[idKey];
    }

    var nameKey = 'name';
    if (map.containsKey(nameKey)) {
      object.name = map[nameKey];
    }

    var descriptionKey = 'description';
    if (map.containsKey(descriptionKey)) {
      object.description = map[descriptionKey];
    }

    var customFieldDataKey = 'customFieldData';
    if (map.containsKey(customFieldDataKey)) {
      object.customFieldData = map[customFieldDataKey];
    }

    var caseDefinitionIdKey = 'caseDefinitionId';
    if (map.containsKey(caseDefinitionIdKey)) {
      object.caseDefinitionId = map[caseDefinitionIdKey];
    }

    var createdAtKey = 'createdAt';
    if (map.containsKey(createdAtKey)) {
      object.createdAt = DateTime.parse(map[createdAtKey]);
    }

    var createdByKey = 'createdBy';
    if (map.containsKey(createdByKey)) {
      object.createdBy = map[createdByKey];
    }

    var updatedAtKey = 'updatedAt';
    if (map.containsKey(updatedAtKey)) {
      object.updatedAt = DateTime.parse(map[updatedAtKey]);
    }

    var updatedByKey = 'updatedBy';
    if (map.containsKey(updatedByKey)) {
      object.updatedBy = map[updatedByKey];
    }

    return object;
  }

  @override
  String toString() {
    return 'Survey{' +
        'id: $id, ' +
        'name: $name, ' +
        'description: $description, ' +
        'customFieldData:$customFieldData, ' +
        'caseDefinitionId:$caseDefinitionId, ' +
        'createdAt: $createdAt, ' +
        'createdAt: $createdBy, ' +
        'updatedAt: $updatedAt, ' +
        'updatedBy: $updatedBy' +
        '}';
  }

  static String getTableName() {
    return 'activity_definitions';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(' +
        'id INTEGER PRIMARY KEY' +
        ', ' +
        'name TEXT' +
        ', ' +
        'description TEXT' +
        ', ' +
        'customFieldData TEXT' +
        ', ' +
        'caseDefinitionId INT NOT NULL' +
        ', ' +
        'createdAt TEXT' + // SQLite "Datetime"
        ', ' +
        'createdBy INT NOT NULL' +
        ', ' +
        'updatedAt TEXT' + // SQLite "Datetime"
        ', ' +
        'updatedBy INT NOT NULL' +
        ', ' +
        'FOREIGN KEY(caseDefinitionId) REFERENCES ' +
        CaseDefinition.getTableName() +
        '(id)' +
        ', ' +
        'FOREIGN KEY(createdBy) REFERENCES ' +
        User.getTableName() +
        '(id)' +
        ', ' +
        'FOREIGN KEY(updatedBy) REFERENCES ' +
        User.getTableName() +
        '(id)' +
        ');';
  }
}
