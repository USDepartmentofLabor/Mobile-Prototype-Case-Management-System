import 'package:eps_mobile/models/case_definition.dart';

class CaseDefinitionDocument {
  int id;
  String name;
  String description;
  bool isRequired;
  int caseDefinitionId;

  CaseDefinitionDocument() {
    this.id = -1;
    this.name = '';
    this.description = '';
    this.isRequired = false;
    this.caseDefinitionId = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isRequired': isRequired.toString(),
      'caseDefinitionId': caseDefinitionId,
    };
  }

  static CaseDefinitionDocument fromMap(Map map) {
    var caseDefinitionDocument = new CaseDefinitionDocument();
    if (map.containsKey('id')) {
      caseDefinitionDocument.id = map['id'];
    }
    if (map.containsKey('name')) {
      caseDefinitionDocument.name = map['name'];
    }
    if (map.containsKey('description')) {
      caseDefinitionDocument.description = map['description'];
    }
    if (map.containsKey('isRequired')) {
      caseDefinitionDocument.isRequired =
          map['isRequired'] == 'true' ? true : false;
    }
    if (map.containsKey('caseDefinitionId')) {
      caseDefinitionDocument.caseDefinitionId = map['caseDefinitionId'];
    }
    return caseDefinitionDocument;
  }

  @override
  String toString() {
    return 'Survey{id: $id, name: $name, description: $description, isRequired: $isRequired, caseDefinitionId: $caseDefinitionId}';
  }

  static String getTableName() {
    return 'case_definition_documents';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(id INTEGER PRIMARY KEY, ' +
        'name TEXT, ' +
        'description TEXT, ' +
        'isRequired INTEGER, ' +
        'caseDefinitionId INT NOT NULL, ' +
        'FOREIGN KEY(caseDefinitionId) REFERENCES ' +
        CaseDefinition.getTableName() +
        '(id));';
  }
}
