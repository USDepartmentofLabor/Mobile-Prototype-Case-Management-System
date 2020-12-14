import 'package:eps_mobile/models/case_definition.dart';
import 'package:eps_mobile/models/case_status.dart';
import 'package:eps_mobile/models/user.dart';

class CaseInstance {
  int id;
  String key;
  String name;
  String description;
  int caseDefinitionId;
  int caseStatusId;
  String customFieldData;

  DateTime createdAt;
  DateTime updatedAt;

  int createdBy;
  int updatedBy;
  int assignedTo;

  // created location
  double createdLatitude;
  double createdlongitude;
  double createdAltitude;
  double createdAltitudeAccuracy;
  double createdPositionAccuracy;
  double createdHeading;
  double createdSpeed;
  DateTime createdRecordedDateTime;

  // updated location
  double updatedLatitude;
  double updatedlongitude;
  double updatedAltitude;
  double updatedAltitudeAccuracy;
  double updatedPositionAccuracy;
  double updatedHeading;
  double updatedSpeed;
  DateTime updatedRecordedDateTime;

  bool markForDeletion;

  bool isLocal;

  CaseInstance() {
    this.id = -1;
    this.key = '';
    this.name = '';
    this.description = '';
    this.caseDefinitionId = -1;
    this.caseStatusId = null;
    this.markForDeletion = false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'description': description,
      'caseDefinitionId': caseDefinitionId,
      'caseStatusId': caseStatusId,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'customFieldData': customFieldData,
      'markForDeletion': markForDeletion,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'assignedTo': assignedTo,
    };
  }

  static CaseInstance fromMap(Map map) {
    var thisCase = new CaseInstance();
    if (map.containsKey('id')) {
      thisCase.id = map['id'];
    }
    if (map.containsKey('key')) {
      thisCase.key = map['key'];
    }
    if (map.containsKey('name')) {
      thisCase.name = map['name'];
    }
    if (map.containsKey('description')) {
      thisCase.description = map['description'];
    }
    if (map.containsKey('caseDefinitionId')) {
      thisCase.caseDefinitionId = map['caseDefinitionId'];
    }
    if (map.containsKey('caseStatusId')) {
      thisCase.caseStatusId = map['caseStatusId'];
    }
    if (map.containsKey('customFieldData')) {
      thisCase.customFieldData = map['customFieldData'];
    }
    if (map.containsKey('markForDeletion')) {
      thisCase.markForDeletion = map['markForDeletion'] == 1 ? true : false;
    }

    var createdAtKey = 'createdAt';
    if (map.containsKey(createdAtKey)) {
      thisCase.createdAt = DateTime.parse(map[createdAtKey]);
    }

    var updatedAtKey = 'updatedAt';
    if (map.containsKey(updatedAtKey)) {
      thisCase.updatedAt = DateTime.parse(map[updatedAtKey]);
    }

    var createdByKey = 'createdBy';
    if (map.containsKey(createdByKey)) {
      thisCase.createdBy = map[createdByKey];
    }

    var updatedByKey = 'updatedBy';
    if (map.containsKey(updatedByKey)) {
      thisCase.updatedBy = map[updatedByKey];
    }

    var assignedToKey = 'assignedTo';
    if (map.containsKey(assignedToKey)) {
      thisCase.assignedTo = map[assignedToKey];
    }

    return thisCase;
  }

  @override
  String toString() {
    return 'Survey{id: $id, key: $key, name: $name, description: $description, caseDefinitionId: $caseDefinitionId, caseStatusId: $caseStatusId}';
  }

  static String getTableName() {
    return 'cases';
  }

  // new cases in a different table
  static String getAltTableName() {
    return 'local_cases';
  }

  static String getCreateTableStatement(String tableName) {
    return 'CREATE TABLE IF NOT EXISTS ' +
        tableName +
        '(id INTEGER PRIMARY KEY, ' +
        'key TEXT, ' +
        'name TEXT, ' +
        'description TEXT, ' +
        'createdAt TEXT, ' + // SQLite "Datetime"
        'createdBy INT' +
        ', ' +
        'updatedAt TEXT, ' + // SQLite "Datetime" +
        'updatedBy INT' +
        ', ' +
        'assignedTo INT' +
        ', ' +
        'caseDefinitionId INT NOT NULL, ' +
        'caseStatusId INT, ' + // is this required? NO
        'customFieldData TEXT, ' +
        'markForDeletion INTEGER, ' +
        'FOREIGN KEY(caseDefinitionId) REFERENCES ' +
        CaseDefinition.getTableName() +
        '(id), ' +
        'FOREIGN KEY(caseStatusId) REFERENCES ' +
        CaseStatus.getTableName() +
        '(id), ' +
        'FOREIGN KEY(createdBy) REFERENCES ' +
        User.getTableName() +
        '(id)' +
        ', ' +
        'FOREIGN KEY(updatedBy) REFERENCES ' +
        User.getTableName() +
        '(id), ' +
        'FOREIGN KEY(assignedTo) REFERENCES ' +
        User.getTableName() +
        '(id)' +
        ');'; // FK
  }
}
