import 'package:eps_mobile/models/activity_definition.dart';

class ActivityDefinitionDocument {
  int id;
  String name;
  String description;
  bool isRequired;
  int activityDefinitionId;

  ActivityDefinitionDocument() {
    this.id = -1;
    this.name = '';
    this.description = '';
    this.isRequired = false;
    this.activityDefinitionId = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isRequired': isRequired.toString(),
      'activityDefinitionId': activityDefinitionId,
    };
  }

  static ActivityDefinitionDocument fromMap(Map map) {
    var object = new ActivityDefinitionDocument();
    if (map.containsKey('id')) {
      object.id = map['id'];
    }
    if (map.containsKey('name')) {
      object.name = map['name'];
    }
    if (map.containsKey('description')) {
      object.description = map['description'];
    }
    if (map.containsKey('isRequired')) {
      object.isRequired = map['isRequired'] == 'true' ? true : false;
    }
    if (map.containsKey('activityDefinitionId')) {
      object.activityDefinitionId = map['activityDefinitionId'];
    }
    return object;
  }

  @override
  String toString() {
    return 'ActivityDefinitionDocument{' +
        'id: $id,' +
        ' ' +
        'name: $name,' +
        ' ' +
        'description: $description,' +
        ' ' +
        'isRequired: $isRequired,' +
        ' ' +
        'activityDefinitionId: $activityDefinitionId' +
        '}';
  }

  static String getTableName() {
    return 'activity_definition_documents';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(id INTEGER PRIMARY KEY, ' +
        'name TEXT, ' +
        'description TEXT, ' +
        'isRequired INTEGER, ' +
        'activityDefinitionId INT NOT NULL, ' +
        'FOREIGN KEY(activityDefinitionId) REFERENCES ' +
        ActivityDefinition.getTableName() +
        '(id));';
  }
}
