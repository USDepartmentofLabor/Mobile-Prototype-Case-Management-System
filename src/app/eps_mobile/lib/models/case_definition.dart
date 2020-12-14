import 'package:eps_mobile/models/case_definition_document.dart';
import 'package:eps_mobile/models/case_definition_survey.dart';

class CaseDefinition {
  int id;
  String name;
  String description;
  String key;
  String customFieldData;

  DateTime createdAt;
  DateTime updatedAt;

  // temp properties for get
  List<CaseDefinitionDocument> documents = new List<CaseDefinitionDocument>();
  List<CaseDefinitionSurvey> surveys = new List<CaseDefinitionSurvey>();

  // Display Properties
  int caseCount = 0;

  CaseDefinition() {
    this.id = -1;
    this.name = '';
    this.description = '';
    this.key = '';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'key': key,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'customFieldData': customFieldData,
    };
  }

  static CaseDefinition fromMap(Map map) {
    var caseDefinition = new CaseDefinition();
    if (map.containsKey('id')) {
      caseDefinition.id = map['id'];
    }
    if (map.containsKey('name')) {
      caseDefinition.name = map['name'];
    }
    if (map.containsKey('description')) {
      caseDefinition.description = map['description'];
    }
    if (map.containsKey('key')) {
      caseDefinition.key = map['key'];
    }
    if (map.containsKey('createdAt')) {
      caseDefinition.createdAt = DateTime.parse(map['createdAt']);
    }
    if (map.containsKey('updatedAt')) {
      caseDefinition.updatedAt = DateTime.parse(map['updatedAt']);
    }
    if (map.containsKey('customFieldData')) {
      caseDefinition.customFieldData = map['customFieldData'];
    }
    return caseDefinition;
  }

  @override
  String toString() {
    return 'Survey{id: $id, name: $name, description: $description, key:$key, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  static String getTableName() {
    return 'case_definitions';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(id INTEGER PRIMARY KEY, ' +
        'name TEXT, ' +
        'description TEXT, ' +
        'key TEXT, ' +
        'customFieldData TEXT, ' +
        'createdAt TEXT, ' + // SQLite "Datetime"
        'updatedAt TEXT' + // SQLite "Datetime"
        ');';
  }
}
