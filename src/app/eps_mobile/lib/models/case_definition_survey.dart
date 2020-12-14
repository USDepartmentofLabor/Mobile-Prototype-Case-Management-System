import 'package:eps_mobile/models/case_definition.dart';
import 'package:eps_mobile/models/survey.dart';

class CaseDefinitionSurvey {
  int caseDefinitionId;
  int surveyId;

  CaseDefinitionSurvey() {
    this.caseDefinitionId = -1;
    this.surveyId = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'caseDefinitionId': caseDefinitionId,
      'surveyId': surveyId,
    };
  }

  static CaseDefinitionSurvey fromMap(Map map) {
    var caseDefinitionSurvey = new CaseDefinitionSurvey();
    if (map.containsKey('caseDefinitionId')) {
      caseDefinitionSurvey.caseDefinitionId = map['caseDefinitionId'];
    }
    if (map.containsKey('surveyId')) {
      caseDefinitionSurvey.surveyId = map['surveyId'];
    }
    return caseDefinitionSurvey;
  }

  @override
  String toString() {
    return 'Survey{caseDefinitionId: $caseDefinitionId, surveyId: $surveyId}';
  }

  static String getTableName() {
    return 'case_definition_surveys';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(' +
        'caseDefinitionId INTEGER, ' +
        'surveyId INTEGER, ' +
        'FOREIGN KEY(caseDefinitionId) REFERENCES ' +
        CaseDefinition.getTableName() +
        '(id), ' +
        'FOREIGN KEY(surveyId) REFERENCES ' +
        Survey.getTableName() +
        '(id), ' +
        'PRIMARY KEY (caseDefinitionId, surveyId)' +
        ');';
  }
}
