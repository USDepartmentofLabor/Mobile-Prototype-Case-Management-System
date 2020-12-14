import 'package:eps_mobile/models/activity_definition.dart';
import 'package:eps_mobile/models/user.dart';

class Activity {
  // fields
  int id;
  String name;
  String description;
  String customFieldData;

  // relationships
  int activityDefinitionId;
  int caseId;

  // datetime and users
  DateTime createdAt;
  int createdBy;

  // created location
  double createdLatitude;
  double createdlongitude;
  double createdAltitude;
  double createdAltitudeAccuracy;
  double createdPositionAccuracy;
  double createdHeading;
  double createdSpeed;
  DateTime createdRecordedDateTime;

  DateTime updatedAt;
  int updatedBy;
  // updated location
  double updatedLatitude;
  double updatedlongitude;
  double updatedAltitude;
  double updatedAltitudeAccuracy;
  double updatedPositionAccuracy;
  double updatedHeading;
  double updatedSpeed;
  DateTime updatedRecordedDateTime;

  // local props
  bool isLocal;

  Activity() {
    this.id = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'customFieldData': customFieldData,
      'activityDefinitionId': activityDefinitionId,
      'caseId': caseId,
      'createdAt': createdAt.toString(),
      'createdBy': createdBy,
      'createdLatitude': createdLatitude,
      'createdlongitude': createdlongitude,
      'createdAltitude': createdAltitude,
      'createdAltitudeAccuracy': createdAltitudeAccuracy,
      'createdPositionAccuracy': createdPositionAccuracy,
      'createdHeading': createdHeading,
      'createdSpeed': createdSpeed,
      'createdRecordedDateTime': createdRecordedDateTime.toString(),
      'updatedAt': updatedAt.toString(),
      'updatedBy': updatedBy,
      'updatedLatitude': updatedLatitude,
      'updatedlongitude': updatedlongitude,
      'updatedAltitude': updatedAltitude,
      'updatedAltitudeAccuracy': updatedAltitudeAccuracy,
      'updatedPositionAccuracy': updatedPositionAccuracy,
      'updatedHeading': updatedHeading,
      'updatedSpeed': updatedSpeed,
      'updatedRecordedDateTime': updatedRecordedDateTime.toString(),
    };
  }

  static Activity fromMap(Map map) {
    var object = Activity();

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

    var activityDefinitionIdKey = 'activityDefinitionId';
    if (map.containsKey(activityDefinitionIdKey)) {
      object.activityDefinitionId = map[activityDefinitionIdKey];
    }

    var caseIdKey = 'caseId';
    if (map.containsKey(caseIdKey)) {
      object.caseId = map[caseIdKey];
    }

    var createdAtKey = 'createdAt';
    if (map.containsKey(createdAtKey)) {
      object.createdAt = DateTime.parse(map[createdAtKey]);
    }

    var createdByKey = 'createdBy';
    if (map.containsKey(createdByKey)) {
      object.createdBy = map[createdByKey];
    }

    var createdLatitudeKey = 'createdLatitude';
    if (map.containsKey(createdLatitudeKey)) {
      if (map[createdLatitudeKey] != null) {
        object.createdLatitude = double.parse(map[createdLatitudeKey]);
      }
    }

    var createdlongitudeKey = 'createdlongitude';
    if (map.containsKey(createdlongitudeKey)) {
      if (map[createdlongitudeKey] != null) {
        object.createdlongitude = double.parse(map[createdlongitudeKey]);
      }
    }

    var createdAltitudeKey = 'createdAltitude';
    if (map.containsKey(createdAltitudeKey)) {
      if (map[createdAltitudeKey] != null) {
        object.createdAltitude = double.parse(map[createdAltitudeKey]);
      }
    }

    var createdAltitudeAccuracyKey = 'createdAltitudeAccuracy';
    if (map.containsKey(createdAltitudeAccuracyKey)) {
      if (map[createdAltitudeAccuracyKey] != null) {
        object.createdAltitudeAccuracy =
            double.parse(map[createdAltitudeAccuracyKey]);
      }
    }

    var createdPositionAccuracyKey = 'createdPositionAccuracy';
    if (map.containsKey(createdPositionAccuracyKey)) {
      if (map[createdPositionAccuracyKey] != null) {
        object.createdPositionAccuracy =
            double.parse(map[createdPositionAccuracyKey]);
      }
    }

    var createdHeadingKey = 'createdHeading';
    if (map.containsKey(createdHeadingKey)) {
      if (map[createdHeadingKey] != null) {
        object.createdHeading = double.parse(map[createdHeadingKey]);
      }
    }

    var createdSpeedKey = 'createdSpeed';
    if (map.containsKey(createdSpeedKey)) {
      if (map[createdSpeedKey] != null) {
        object.createdSpeed = double.parse(map[createdSpeedKey]);
      }
    }

    var updatedAtKey = 'updatedAt';
    if (map.containsKey(updatedAtKey)) {
      object.updatedAt = DateTime.parse(map[updatedAtKey]);
    }

    var updatedByKey = 'updatedBy';
    if (map.containsKey(updatedByKey)) {
      object.updatedBy = map[updatedByKey];
    }

    var updatedLatitudeKey = 'updatedLatitude';
    if (map.containsKey(updatedLatitudeKey)) {
      if (map[updatedLatitudeKey] != null) {
        object.updatedLatitude = double.parse(map[updatedLatitudeKey]);
      }
    }

    var updatedlongitudeKey = 'updatedlongitude';
    if (map.containsKey(updatedlongitudeKey)) {
      if (map[updatedlongitudeKey] != null) {
        object.updatedlongitude = double.parse(map[updatedlongitudeKey]);
      }
    }

    var updatedAltitudeKey = 'updatedAltitude';
    if (map.containsKey(updatedAltitudeKey)) {
      if (map[updatedAltitudeKey] != null) {
        object.updatedAltitude = double.parse(map[updatedAltitudeKey]);
      }
    }

    var updatedAltitudeAccuracyKey = 'updatedAltitudeAccuracy';
    if (map.containsKey(updatedAltitudeAccuracyKey)) {
      if (map[updatedAltitudeAccuracyKey] != null) {
        object.updatedAltitudeAccuracy =
            double.parse(map[updatedAltitudeAccuracyKey]);
      }
    }

    var updatedPositionAccuracyKey = 'updatedPositionAccuracy';
    if (map.containsKey(updatedPositionAccuracyKey)) {
      if (map[updatedPositionAccuracyKey] != null) {
        object.updatedPositionAccuracy =
            double.parse(map[updatedPositionAccuracyKey]);
      }
    }

    var updatedHeadingKey = 'updatedHeading';
    if (map.containsKey(updatedHeadingKey)) {
      if (map[updatedHeadingKey] != null) {
        object.updatedHeading = double.parse(map[updatedHeadingKey]);
      }
    }

    var updatedSpeedKey = 'updatedSpeed';
    if (map.containsKey(updatedSpeedKey)) {
      if (map[updatedSpeedKey] != null) {
        object.updatedSpeed = double.parse(map[updatedSpeedKey]);
      }
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
        'activityDefinitionId:$activityDefinitionId, ' +
        'caseId:$caseId' +
        'createdAt: $createdAt, ' +
        'createdAt: $createdBy, ' +
        'createdLatitude: $createdLatitude, ' +
        'createdlongitude: $createdlongitude, ' +
        'createdAltitude: $createdAltitude, ' +
        'createdAltitudeAccuracy: $createdAltitudeAccuracy, ' +
        'createdPositionAccuracy: $createdPositionAccuracy, ' +
        'createdHeading: $createdHeading, ' +
        'createdSpeed: $createdSpeed, ' +
        'createdRecordedDateTime: $createdRecordedDateTime, ' +
        'updatedAt: $updatedAt, ' +
        'updatedBy: $updatedBy' +
        'updatedLatitude: $updatedLatitude, ' +
        'updatedlongitude: $updatedlongitude, ' +
        'updatedAltitude: $updatedAltitude, ' +
        'updatedAltitudeAccuracy: $updatedAltitudeAccuracy, ' +
        'updatedPositionAccuracy: $updatedPositionAccuracy, ' +
        'updatedHeading: $updatedHeading, ' +
        'updatedSpeed: $updatedSpeed, ' +
        'updatedRecordedDateTime: $updatedRecordedDateTime, ' +
        '}';
  }

  static String getTableName() {
    return 'activities';
  }

  static String getLocalTableName() {
    return 'local_activities';
  }

  // new objects in 2 different tables
  static String getTableNameLocalRelLocalCases() {
    return 'local_activities_rel_local_cases';
  }

  static String getTableNameLocalRelServerCases() {
    return 'local_activities_rel_server_cases';
  }

  static String getCreateTableStatement(
    String tableName,
    String caseTableName,
  ) {
    return 'CREATE TABLE IF NOT EXISTS ' +
        tableName +
        '(' +
        'id INTEGER PRIMARY KEY' +
        ', ' +
        'name TEXT' +
        ', ' +
        'description TEXT' +
        ', ' +
        'customFieldData TEXT' +
        ', ' +
        'activityDefinitionId INT NOT NULL' +
        ', ' +
        'caseId INT NOT NULL' +
        ', ' +
        'createdAt TEXT' + // SQLite "Datetime"
        ', ' +
        'createdBy INT NOT NULL' +
        ', ' +
        'createdLatitude REAL' +
        ', ' +
        'createdlongitude REAL' +
        ', ' +
        'createdAltitude REAL' +
        ', ' +
        'createdAltitudeAccuracy REAL' +
        ', ' +
        'createdPositionAccuracy REAL' +
        ', ' +
        'createdHeading REAL' +
        ', ' +
        'createdSpeed REAL' +
        ', ' +
        'createdRecordedDateTime TEXT' + // SQLite "Datetime"
        ', ' +
        'updatedAt TEXT' + // SQLite "Datetime"
        ', ' +
        'updatedBy INT NOT NULL' +
        ', ' +
        'updatedLatitude REAL' +
        ', ' +
        'updatedlongitude REAL' +
        ', ' +
        'updatedAltitude REAL' +
        ', ' +
        'updatedAltitudeAccuracy REAL' +
        ', ' +
        'updatedPositionAccuracy REAL' +
        ', ' +
        'updatedHeading REAL' +
        ', ' +
        'updatedSpeed REAL' +
        ', ' +
        'updatedRecordedDateTime TEXT' + // SQLite "Datetime"
        ', ' +
        'FOREIGN KEY(activityDefinitionId) REFERENCES ' +
        ActivityDefinition.getTableName() +
        '(id)' +
        ', ' +
        'FOREIGN KEY(caseId) REFERENCES ' +
        caseTableName +
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
