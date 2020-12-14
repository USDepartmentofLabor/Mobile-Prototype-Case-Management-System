import 'dart:convert';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/models/survey_response_status.dart';
import 'package:eps_mobile/models/user.dart';

enum SurveyResponseCaseModelType {
  Case,
  LocalCase,
}

enum SurveyResponseActivityModelType {
  ServerCaseServerActivity, // ServerCase => ServerActivity
  ServerCaseLocalActivity, // ServerCase => LocalActivity
  LocalCaseLocalActivity // LocalCase => LocalActivity
  // LocalCase => ServerActivity should not exist!!!
}

class SurveyResponse {
  int id;
  int surveyId;
  Map structure;
  int statusId;
  String sourceType;

  DateTime createdAt;
  DateTime updatedAt;

  int createdBy;
  int updatedBy;

  bool isArchived;

  // relations
  String caseModelType;
  int caseId;

  String activityModelType;
  int activityId;

  // ignore
  // created_location
  // updated_location

  SurveyResponse() {
    this.id = -1;
    this.structure = {};
    this.sourceType = '';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surveyId': surveyId,
      'structure': json.encode(structure),
      'statusId': statusId,
      'sourceType': sourceType,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'isArchived': isArchived.toString(),
      'caseModelType': caseModelType,
      'caseId': caseId,
      'activityModelType': activityModelType,
      'activityId': activityId,
    };
  }

  static SurveyResponse fromMap(Map map) {
    var surveyResponse = new SurveyResponse();
    if (map.containsKey('id')) {
      surveyResponse.id = map['id'];
    }

    if (map.containsKey('surveyId')) {
      surveyResponse.surveyId = map['surveyId'];
    }

    if (map.containsKey('structure')) {
      surveyResponse.structure = json.decode(map['structure']);
    }

    if (map.containsKey('statusId')) {
      surveyResponse.statusId = map['statusId'];
    }

    if (map.containsKey('sourceType')) {
      surveyResponse.sourceType = map['sourceType'];
    }

    if (map.containsKey('createdAt')) {
      surveyResponse.createdAt = DateTime.parse(map['createdAt']);
    }

    if (map.containsKey('updatedAt')) {
      surveyResponse.updatedAt = DateTime.parse(map['updatedAt']);
    }

    if (map.containsKey('createdBy')) {
      surveyResponse.createdBy = map['createdBy'];
    }

    if (map.containsKey('updatedBy')) {
      surveyResponse.updatedBy = map['updatedBy'];
    }

    if (map.containsKey('isArchived')) {
      surveyResponse.isArchived = map['is_archived'] == 'True';
    }

    if (map.containsKey('caseModelType')) {
      surveyResponse.caseModelType = map['caseModelType'];
    }

    if (map.containsKey('caseId')) {
      surveyResponse.caseId = map['caseId'];
    }

    if (map.containsKey('activityModelType')) {
      surveyResponse.activityModelType = map['activityModelType'];
    }

    if (map.containsKey('activityId')) {
      surveyResponse.activityId = map['activityId'];
    }

    return surveyResponse;
  }

  @override
  String toString() {
    return 'Survey{' +
        'id: $id, ' +
        'survey_id: $surveyId, ' +
        'structure: $structure, ' +
        'statusId: $statusId, ' +
        'sourceType: $sourceType, ' +
        'createdAt: $createdAt, ' +
        'updatedAt: $updatedAt, ' +
        'createdBy: $createdBy, ' +
        'updatedBy: $updatedBy, ' +
        'isArchived: $isArchived, ' +
        'caseModelType: $caseModelType, ' +
        'caseId: $caseId, ' +
        'activityModelType: $activityModelType, ' +
        'activityId: $activityId, ' +
        '}';
  }

  static String getTableName() {
    return 'survey_responses';
  }

  // new responses in a different table
  static String getAltTableName() {
    return 'local_survey_responses';
  }

  static String getCreateTableStatement(String tableName) {
    return 'CREATE TABLE IF NOT EXISTS ' +
        tableName +
        '(' +
        'id INTEGER PRIMARY KEY' +
        ', ' +
        'surveyId INT NOT NULL' +
        ', ' +
        'structure TEXT' +
        ', ' +
        'statusId INT' +
        ', ' +
        'sourceType TEXT' +
        ', ' +
        'createdAt TEXT' + // SQLite "Datetime"
        ', ' +
        'updatedAt TEXT' + // SQLite "Datetime"
        ', ' +
        'createdBy INT' +
        ', ' +
        'updatedBy INT' +
        ', ' +
        'isArchived INTEGER' +
        ', ' +
        'caseModelType TEXT' +
        ', ' +
        'caseId INT' +
        ', ' +
        'activityModelType TEXT' +
        ', ' +
        'activityId INT' +
        ', ' +
        'FOREIGN KEY(surveyId) REFERENCES ' +
        Survey.getTableName() +
        '(id)' +
        ', ' +
        'FOREIGN KEY (statusId) REFERENCES ' +
        SurveyResponseStatus.getTableName() +
        '(id)' +
        ', ' +
        'FOREIGN KEY (createdBy) REFERENCES ' +
        User.getTableName() +
        '(id)' +
        ', ' +
        'FOREIGN KEY (updatedBy) REFERENCES ' +
        User.getTableName() +
        '(id)' +
        // no fk for caseId since using modelType
        // no fk for activityId since using modelType
        ');';
  }
}
