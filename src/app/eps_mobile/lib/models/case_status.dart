class CaseStatus {
  bool isDefault;
  int id;
  String name;
  bool isFinal;
  String color;

  CaseStatus() {
    this.isDefault = false;
    this.id = -1;
    this.isFinal = false;
  }

  Map<String, dynamic> toMap() {
    return {
      'isDefault': isDefault,
      'id': id,
      'name': name,
      'isFinal': isFinal,
      'color': color,
    };
  }

  static CaseStatus fromMap(Map map) {
    var caseStatus = new CaseStatus();

    var isDefaultKey = 'isDefault';
    if (map.containsKey(isDefaultKey)) {
      caseStatus.isDefault = map[isDefaultKey] == 'true' ? true : false;
    }

    var idKey = 'id';
    if (map.containsKey(idKey)) {
      caseStatus.id = map[idKey];
    }

    var nameKey = 'name';
    if (map.containsKey(nameKey)) {
      caseStatus.name = map[nameKey];
    }

    var isFinalKey = 'isFinal';
    if (map.containsKey(isFinalKey)) {
      caseStatus.isFinal = map[isFinalKey] == 'true' ? true : false;
    }

    var colorKey = 'color';
    if (map.containsKey(colorKey)) {
      caseStatus.color = map[colorKey];
    }

    return caseStatus;
  }

  @override
  String toString() {
    return 'CaseStatus{' +
        'isDefault: $isDefault, ' +
        'id: $id, ' +
        'name: $name, ' +
        'isFinal: $isFinal, ' +
        'color: $color' +
        '}';
  }

  static String getTableName() {
    return 'case_statuses';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(' +
        'isDefault INT' +
        ', ' +
        'id INTEGER PRIMARY KEY' +
        ', ' +
        'name TEXT' +
        ', ' +
        'isFinal INT' +
        ', ' +
        'color TEXT' +
        ');';
  }
}
