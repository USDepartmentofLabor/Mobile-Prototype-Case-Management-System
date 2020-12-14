import 'package:eps_mobile/models/activity_definition_document.dart';
import 'package:eps_mobile/models/survey.dart';

class ActivityDefinitionSurvey {
  int activityDefinitionId;
  int surveyId;

  ActivityDefinitionSurvey() {
    this.activityDefinitionId = -1;
    this.surveyId = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'activityDefinitionId': activityDefinitionId,
      'surveyId': surveyId,
    };
  }

  static ActivityDefinitionSurvey fromMap(Map map) {
    var object = new ActivityDefinitionSurvey();
    if (map.containsKey('activityDefinitionId')) {
      object.activityDefinitionId = map['activityDefinitionId'];
    }
    if (map.containsKey('surveyId')) {
      object.surveyId = map['surveyId'];
    }
    return object;
  }

  @override
  String toString() {
    return 'Survey{' +
        'activityDefinitionId: $activityDefinitionId' +
        ', ' +
        'surveyId: $surveyId' +
        '}';
  }

  static String getTableName() {
    return 'activity_definition_surveys';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(' +
        'activityDefinitionId INTEGER, ' +
        'surveyId INTEGER, ' +
        'FOREIGN KEY(activityDefinitionId) REFERENCES ' +
        ActivityDefinitionDocument.getTableName() +
        '(id), ' +
        'FOREIGN KEY(surveyId) REFERENCES ' +
        Survey.getTableName() +
        '(id), ' +
        'PRIMARY KEY (activityDefinitionId, surveyId)' +
        ');';
  }
}
