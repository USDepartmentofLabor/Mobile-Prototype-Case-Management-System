class SurveyResponseStatus {
  bool isDefault;
  int id;
  String name;

  SurveyResponseStatus() {
    this.isDefault = false;
    this.id = -1;
    this.name = '';
  }

  Map<String, dynamic> toMap() {
    return {
      'isDefault': isDefault,
      'id': id,
      'name': name,
    };
  }

  static SurveyResponseStatus fromMap(Map map) {
    var surveyResponseStatus = new SurveyResponseStatus();
    if (map.containsKey('isDefault')) {
      surveyResponseStatus.isDefault = map['isDefault'] == 1 ? true : false;
    }
    if (map.containsKey('id')) {
      surveyResponseStatus.id = map['id'];
    }
    if (map.containsKey('name')) {
      surveyResponseStatus.name = map['name'];
    }
    return surveyResponseStatus;
  }

  @override
  String toString() {
    return 'SurveyResponseStatus{isDefault: $isDefault, id: $id, name: $name}';
  }

  static String getTableName() {
    return 'survey_response_statuses';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(' +
        'isDefault INT,' +
        'id INTEGER PRIMARY KEY, ' +
        'name TEXT' +
        ');';
  }
}
