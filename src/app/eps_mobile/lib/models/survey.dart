import 'dart:convert';
import 'package:eps_mobile/models/user.dart';

class Survey {
  int id;
  String name;
  Map structure;

  DateTime createdAt;
  DateTime updatedAt;

  int createdBy;
  int updatedBy;

  bool isArchived;
  //bool originatedLocal;

  // Display Properties
  int responseCount = 0;
  int responseCountNonArchived = 0;

  List<int> responseIds = new List<int>();

  Survey() {
    this.id = 1;
    this.name = '';
    this.structure = {};
    this.createdAt = null;
    this.updatedAt = null;
    this.isArchived = false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'structure': json.encode(structure),
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'isArchived': isArchived.toString(),
    };
  }

  static Survey fromMap(Map map) {
    var survey = new Survey();
    if (map.containsKey('id')) {
      survey.id = map['id'];
    }
    if (map.containsKey('name')) {
      survey.name = map['name'];
    }
    if (map.containsKey('structure')) {
      survey.structure = json.decode(map['structure']);
    }
    if (map.containsKey('createdAt')) {
      survey.createdAt = DateTime.parse(map['createdAt']);
    }
    if (map.containsKey('updatedAt')) {
      survey.updatedAt = DateTime.parse(map['updatedAt']);
    }
    if (map.containsKey('isArchived')) {
      survey.isArchived = map['is_archived'] == 'True';
    }

    if (map.containsKey('createdBy')) {
      survey.createdBy = map['createdBy'];
    }
    if (map.containsKey('updatedBy')) {
      survey.updatedBy = map['updatedBy'];
    }
    return survey;
  }

  @override
  String toString() {
    return 'Survey{id: $id, name: $name, structure: $structure, createdAt: $createdAt, updatedAt: $updatedAt, isArchived: $isArchived}';
  }

  static String getTableName() {
    return 'surveys';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(id INTEGER PRIMARY KEY' +
        ', ' +
        'name TEXT' +
        ', ' +
        'structure TEXT' +
        ', ' +
        'createdAt TEXT' + // SQLite "Datetime"
        ', ' +
        'updatedAt TEXT' + // SQLite "Datetime"
        ', ' +
        'isArchived INTEGER' +
        ', ' +
        'createdBy INT' +
        ', ' +
        'updatedBy INT' +
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
